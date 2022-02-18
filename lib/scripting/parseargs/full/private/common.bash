#!/usr/bin/env bash
# ====================================================================================================================================
# @file     common.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified Friday, 18th February 2022 8:28:36 pm
# @project  bash-utils
# @brief
#    
#    Set of utilities common for all submodules
#
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# A string reporting a library bug
declare __parsargs_bug_msg_=$(echo \
        "A @fun parseargs failed to parse it's own options. This is a library bug. Please" \
        "report it to the librarie's author."
)

# Interdation argument's description
declare ARGUMENTS_DESCRIPTION_INTEND="${ARGUMENTS_DESCRIPTION_INTEND:-5}"
# Maximal lenght of the argument's description
declare ARGUMENTS_DESCRIPTION_LENGTH_MAX="${ARGUMENTS_DESCRIPTION_LENGTH_MAX:-85}"

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Parses [format] and [help] fields from the UBAD table
# 
# @param defs
#   name of the UBAD list describing arguments
# @param formats [out]
#   name of the hash array that the [format] fields will be parsed into
# @param helps [out]
#   name of the hash array that the [help] fields will be parsed into
# @param types [out]
#   name of the hash array that the [type] fields will be parsed into
# ---------------------------------------------------------------------------------------
function parse_description_info() {

    # Parse arguments
    local __parse_description_info_defs_="$1"
    local __parse_description_info_formats_="$2"
    local __parse_description_info_helps_="$3"
    local __parse_description_info_types_="$4"

    # Parse formats
    parse_ubad_tables_field               \
        "$__parse_description_info_defs_" \
        'format'                          \
        "$__parse_description_info_formats_"

    # Parse help strings
    parse_ubad_tables_field               \
        "$__parse_description_info_defs_" \
        'help'                            \
        "$__parse_description_info_helps_"

    # Parse type strings
    parse_ubad_tables_field               \
        "$__parse_description_info_defs_" \
        'type'                            \
        "$__parse_description_info_types_"

    # Get reference to both harrays
    local -n __parse_description_info_formats_ref_="$__parse_description_info_formats_"
    local -n __parse_description_info_helps_ref_="$__parse_description_info_helps_"

    local name
    
    # Iterate over formats and reformat them into prettier form
    for name in "${!__parse_description_info_formats_ref_[@]}"; do
        
        # Extend formats with additional indentation
        __parse_description_info_formats_ref_[$name]=$(
            printf "%-${ARGUMENTS_DESCRIPTION_INTEND}s%s" "" "${__parse_description_info_formats_ref_[$name]}")
        # If [help] was not given, add an empty one
        is_var_set __parse_description_info_helps_ref_["$name"] || \
            __parse_description_info_helps_ref_["$name"]=""
        # If [type] was not given, add an default one
        is_var_set __parse_description_info_types_ref_["$name"] || \
            __parse_description_info_types_ref_["$name"]="string"

    done

}


# ---------------------------------------------------------------------------------------
# @brief Based on the [format] and [help] fields from the UBAD tables compiles a pretty
#    description of arguments of the given type
# 
# @param formats
#   name of the hash array that the [format] fields will be parsed into
# @param helps
#   name of the hash array that the [help] fields will be parsed into
#
# @outputs 
#    compiled description
# ---------------------------------------------------------------------------------------
function compile_description_info() {

    # Parse arguments
    local -n __compile_description_info_formats_="$1"
    local -n __compile_description_info_helps_="$2"

    local name=""
    
    # Prepare maximum length of the format string
    local -i max_format_length=$(max_len __compile_description_info_formats_)
    # Print full descriptions
    for name in "${!__compile_description_info_formats_[@]}"; do
        
        # Create format string (left-aligned)
        local description=$(printf "%-${max_format_length}s " "${__compile_description_info_formats_[$name]}")
        
        # Enable word splitting (locally)
        localize_word_splitting
        enable_word_splitting

        local word=""

        # Number of characters written in the row
        local chars_in_row
        (( chars_in_row = $max_format_length + 2 ))

        # Loop over words in the description and print them so that it fits in required width
        for word in ${__compile_description_info_helps_[$name]}; do
        
            if (( $chars_in_row + 1 + ${#word} <= $ARGUMENTS_DESCRIPTION_LENGTH_MAX )); then

                # Add number of characters in row
                (( chars_in_row = ${chars_in_row} + 1 + ${#word}))
                # Print word
                description+=" ${word}"

            # Else, if word does NOT fit into description, go to the next line
            else

                # Set number of characters in row
                (( chars_in_row = ${max_format_length} + 2 + ${#word}))
                # Print word with intendation
                description+=$(printf "\n%-${max_format_length}s  %s" " " "${word}") 

            fi
            
        done

        # Disable word splitting
        disable_word_splitting

        # Print description of the option
        echo "${description}"

    done

}

# ========================================================= Implementations ======================================================== #

# ---------------------------------------------------------------------------------------
# @brief Applies default values to non-parsed arguments from the set of defined ones
#
# @param defs
#    name of the hash array holding arguments definitions (UBAD list)
# @param types [out]
#    name of the hash array holding parsed arguments
#
# @returns 
#    @retval @c 0 on success
# ---------------------------------------------------------------------------------------
function apply_defaults() {

    # Parse arguments
    local      __apply_defaults_defs_="$1"
    local -n __apply_defaults_parsed_="$2"

    # Hash array holding list of default values corresponding to non-flag arguments' names
    local -A __apply_defaults_defaults_
    
    # Parse default values
    parse_ubad_tables_field_no_flags \
        ${__apply_defaults_defs_}    \
        'default'                    \
        __apply_defaults_defaults_

    local defaulted

    # Iterate through provided defaults
    for defaulted in "${!__apply_defaults_defaults_[@]}"; do
        # If option has not been parsed, write the default option
        if ! is_var_set __apply_defaults_parsed_["$defaulted"]; then
            __apply_defaults_parsed_["$defaulted"]=${__apply_defaults_defaults_[$defaulted]}
        fi
    done
}

# ---------------------------------------------------------------------------------------
# @brief Verifies whether integer-typed parameters parsed by the caller in fact 
#    represent integers
#
# @param parsed
#    name of the hash array holding parsed arguments
# @param types
#    name of the hash array holding types of valid arguments
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 if a key present in @p parsed hash array is not present in @p types
#       hash array
#    @retval @c 2 if a non-integer value has been parsed for integer-typed argument
# ---------------------------------------------------------------------------------------
function verify_parsed_integers() {

    # Parse arguments
    local -n __verify_parsed_integers_parsed_="$1"
    local -n __verify_parsed_integers_types_="$2"

    local name

    # Iterate through parsed options
    for name in "${!__verify_parsed_integers_parsed_[@]}"; do

        is_var_set __verify_parsed_integers_types_[$name] || {
            log_error "$__parseargs_bug_msg_"
            return 1
        }

        # Check if option is integer-typed
        if is_ubad_arg_integer "${__verify_parsed_integers_types_[$name]}"; then

            # Get the parse value
            local parsed_value="${__verify_parsed_integers_parsed_[$name]}"
            
            # Check if option's value represents integer
            if ! represents_integer "$parsed_value"; then
                log_error "($parsed_value) passed to integer-typed argument '$name'"
                return 2
            fi
        fi
    done

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Verifies whether integer-typed parameters parsed by the caller in fact 
#    represent integers
#
# @param definitions
#    name of the UBAD list holding definitions of arguments to be verified
# @param types
#    name of the hash array holding name-type pairs; such information can be
#    derived from @p definitions but as it is created by the calling functions
#    (i.e. parseopts, parseenvs, parsepargs) before calling this function it can
#    be passed directly to save computation time
# @param stringifier
#    string containing command outputting human-readable name of the argument
#    that will be printed when the verification fails. Arguments passed to the command
#    are @p definitions and the ubad-name of the argument respectively
# @param raw 
#    either 'default' or 'raw'; decides whether [variants] and [range] fields of the
#    UBAD tables are parsed with or without trimming subsequent fields
# @param parsed
#    name of the hash array holding values of parsed arguments described by the 
#    @p definitions
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 if a key present in @p parsed hash array is not present in @p types
#       hash array
#    @retval @c 2 if a non-integer value has been parsed for integer-typed argument
#
# @todo Add automatical printing of 
#    - default values
#    - valid variants
#    - valid ranges
# ---------------------------------------------------------------------------------------
function verify_variants_and_ranges() {

    # Parse arguments
    local    __verify_variants_and_ranges_definitions_="$1"
    local -n __verify_variants_and_ranges_types_="$2"
    local    __verify_variants_and_ranges_stringifier_="$3"
    local    __verify_variants_and_ranges_raw_="$4"
    local -n __verify_variants_and_ranges_parsed_="$5"

    # ------------------ Parse variants/ranges definitions --------------------

    # Hash array holding list of variants corresponding to non-flag arguments' names
    local -A __verify_variants_and_ranges_variants_
    # Parse variants values
    parse_ubad_tables_field_no_flags                 \
        ${__verify_variants_and_ranges_definitions_} \
        'variants'                                   \
        __verify_variants_and_ranges_variants_

    # Hash array holding list of ranges corresponding to non-flag arguments' names
    local -A __verify_variants_and_ranges_ranges_
    # Parse ranges values
    parse_ubad_tables_field_no_flags                 \
        ${__verify_variants_and_ranges_definitions_} \
        'range'                            \
        __verify_variants_and_ranges_ranges_

    # --------------- Verify if variants/ranges are respected -----------------
    
    # Iterate through parsed arguments
    for name in "${!__verify_variants_and_ranges_parsed_[@]}"; do
        # Skip flag arguments
        if ! is_ubad_arg_flag "${__verify_variants_and_ranges_types_[$name]}"; then

            # If variants are defined for the option
            if is_var_set __verify_variants_and_ranges_variants_["$name"]; then
                
                # Array holding valid variants of the option
                local -a variants=()
                # Parse variants
                parse_vatiants                                         \
                    "${__verify_variants_and_ranges_variants_[$name]}" \
                    "${__verify_variants_and_ranges_raw_}"             \
                    variants
                
                # Check whether option's value meet valid variants
                is_array_element variants "${__verify_variants_and_ranges_parsed_[$name]}" ||
                {
                    log_error \
                        "Argument '$($__verify_variants_and_ranges_stringifier_ $__verify_variants_and_ranges_definitions_ $name)' " \
                        "parsed with value (${__verify_variants_and_ranges_parsed_[$name]}) when one of" \
                        "{ ${__verify_variants_and_ranges_variants_[$name]} } is required"
                    return 2
                }

            # Else, if range is defined for the option
            elif is_var_set __verify_variants_and_ranges_ranges_["$name"]; then

                # Limits of the valid range
                local min
                local max
                # Parse variants
                parse_range                                          \
                    "${__verify_variants_and_ranges_ranges_[$name]}" \
                    "${__verify_variants_and_ranges_raw_}"           \
                    min max

                local min_valid
                local max_valid

                # For integer-typed variables, use numerical comparisons
                if is_ubad_arg_integer "${__verify_variants_and_ranges_types_[$name]}"; then
                    (( "$min" > "${__verify_variants_and_ranges_parsed_[$name]}" )) && min_valid=1 || min_valid=0
                    (( "$max" < "${__verify_variants_and_ranges_parsed_[$name]}" )) && max_valid=1 || max_valid=0
                # For other-typed variables, use lexicalographical comparisons
                else
                    [[ "$min" > "${__verify_variants_and_ranges_parsed_[$name]}" ]] && min_valid=1 || min_valid=0
                    [[ "$max" < "${__verify_variants_and_ranges_parsed_[$name]}" ]] && max_valid=1 || max_valid=0
                fi

                # Check whether option's value meet valid variants
                if [[ "$min_valid" != "0" ]] || [[ "$max_valid" != "0" ]]; then

                    log_error \
                        "Argument '$($__verify_variants_and_ranges_stringifier_ $__verify_variants_and_ranges_definitions_ $name)' " \
                        "parsed with value (${__verify_variants_and_ranges_parsed_[$name]}) when it is limited to ( $min : $max ) range"
                    return $ret_

                fi
            fi
            
        fi
    done

    return 0
}

# ================================================================================================================================== #
