#!/usr/bin/env bash
# ====================================================================================================================================
# @file     common.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified   Friday, 10th June 2022 1:29:22 pm
# @project  bash-utils
# @brief
#    
#    Set of utilities common for all submodules
#
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# A string reporting a library bug
declare __lib_bug_msg_=$(echo \
    "An internal error occurred in the \`parseargs\` library Please report it to the librarie's author."
)

# Interdation argument's description
declare ARGUMENTS_DESCRIPTION_INTEND="${ARGUMENTS_DESCRIPTION_INTEND:-4}"
# Maximal lenght of the argument's description
declare ARGUMENTS_DESCRIPTION_LENGTH_MAX="${ARGUMENTS_DESCRIPTION_LENGTH_MAX:-85}"

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Parses [format] and [help] fields from the UBAD table
# 
# @param defs
#   name of the UBAD list describing arguments
# @param parse_mode ( optional, default: 'default' )
#    parse mode (either 'default' - list element's will be trimmed - or 'raw' - list 
#    element's will NOT be trimmed)
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
    local __parse_description_info_parse_mode_="${2:-default}"
    local __parse_description_info_formats_="$3"
    local __parse_description_info_helps_="$4"
    local __parse_description_info_types_="$5"

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
    local -n __parse_description_info_types_ref_="$__parse_description_info_types_"

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

    # Get reference to the definitions
    local -n __parse_description_info_defs_ref_="$__parse_description_info_defs_"

    local descriptor

    # Iterate over arguments' definitions and append information about default values and valid ranges/variants
    for descriptor in "${__parse_description_info_defs_ref_[@]}"; do

        # Get reference to the given argument's descriptor
        local -n descriptor_ref="$descriptor"
        # Get option's name
        local name="${descriptor_ref[name]}"

        # Check if there is additional information to be included into the help string
        if is_var_set descriptor_ref[default] || is_var_set descriptor_ref[variants] || is_var_set descriptor_ref[range]; then

            # Open parenthesis for additional info
            __parse_description_info_helps_ref_["$name"]+=" ("

            # If there is a default value of the argument
            if is_var_set descriptor_ref[default]; then

                # Append this value
                __parse_description_info_helps_ref_["$name"]+="default: ${descriptor_ref[default]}"
                # Put a trailing comma, if valid range/variants are defined
                if is_var_set descriptor_ref[variants] || is_var_set descriptor_ref[range]; then
                    __parse_description_info_helps_ref_["$name"]+=", "
                fi

            fi

            # If there is a variants value of the argument, append them into help
            if is_var_set descriptor_ref[variants]; then

                local -a variants

                # Parse list of variants
                parse_vatiants                              \
                    "${descriptor_ref[variants]}"           \
                    "$__parse_description_info_parse_mode_" \
                    variants
            
                local var

                # Start variants' listing
                __parse_description_info_helps_ref_["$name"]+="valid values: {"
                # Print variants
                for var in "${variants[@]}"; do
                    __parse_description_info_helps_ref_["$name"]+="$var, "
                done
                # Get help string
                local help="${__parse_description_info_helps_ref_[$name]}"
                # Remove trailing comma
                __parse_description_info_helps_ref_["$name"]="${help::-2}"
                # End variants' listing
                __parse_description_info_helps_ref_["$name"]+="}"

            # Else, if there is a valid range of the argument, append it into help
            elif is_var_set descriptor_ref[range]; then            

                local min
                local max

                # Parse the range
                parse_range                                 \
                    "${descriptor_ref[range]}"              \
                    "$__parse_description_info_parse_mode_" \
                    min max

                # Append the range to the help string
                __parse_description_info_helps_ref_["$name"]+="valid range: [$min:$max]"

            fi

            # Close parenthesis for additional info
            __parse_description_info_helps_ref_["$name"]+=")"

        fi

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
    
    # -------------------------------------------------------
    # @brief Prepare output array. Unfortunatelly, when the
    #    @p formats array is is iterated, it's keys are
    #    processed in the reversed order comparing to the
    #    order of their adding. It results in arguments'
    #    descriptions being printed in the reverse order
    #  
    #    To fix that, the temporary array is created to hold
    #    description strings of subsequent arguments
    #    At the end of the function content of this array
    #    is printed out in the reverse order 
    # -------------------------------------------------------
    local -a __compile_description_info_result_=()

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
        __compile_description_info_result_+=( "${description}" )

    done

    local i
    
    # Print result in the reverse order
    for ((i = ${#__compile_description_info_result_[@]} - 1; i >= 0 ; i--)); do
        echo "${__compile_description_info_result_[$i]}"
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
            log_error "$__lib_bug_msg_"
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

        # Get type string for the argument
        local type_str=""
        # Check just te name of the argument
        if is_var_set __verify_variants_and_ranges_types_["$name"]; then
            type_str="${__verify_variants_and_ranges_types_[$name]}"
        # Check also name with trailing digits removed for case of multipack/variaidic arguments
        elif is_var_set __verify_variants_and_ranges_types_["${name%*([[:digit:]])}"]; then
            local trailed_name="${name%*([[:digit:]])}"
            type_str="${__verify_variants_and_ranges_types_[$trailed_name]}"
        fi
        
        # Skip flag arguments
        if ! is_ubad_arg_flag "$type_str"; then

            # Get variants string for the argument
            local variants_str=""
            # Check just te name of the argument
            if is_var_set __verify_variants_and_ranges_variants_["$name"]; then
                variants_str="${__verify_variants_and_ranges_variants_[$name]}"
            # Check also name with trailing digits removed for case of multipack/variaidic arguments
            elif is_var_set __verify_variants_and_ranges_variants_["${name%*([[:digit:]])}"]; then
                local trailed_name="${name%*([[:digit:]])}"
                variants_str="${__verify_variants_and_ranges_variants_[$trailed_name]}"
            fi

            # Get ranges string for the argument
            local range_str=""
            # Check just te name of the argument
            if is_var_set __verify_variants_and_ranges_ranges_["$name"]; then
                range_str="${__verify_variants_and_ranges_ranges_[$name]}"
            # Check also name with trailing digits removed for case of multipack/variaidic arguments
            elif is_var_set __verify_variants_and_ranges_ranges_["${name%*([[:digit:]])}"]; then
                local trailed_name="${name%*([[:digit:]])}"
                range_str="${__verify_variants_and_ranges_ranges_[$trailed_name]}"
            fi

            # If variants are defined for the option
            if is_var_set_non_empty variants_str; then
                
                # Array holding valid variants of the option
                local -a variants=()
                # Parse variants
                parse_vatiants                             \
                    "$variants_str"                        \
                    "${__verify_variants_and_ranges_raw_}" \
                    variants
                
                # Check whether option's value meet valid variants
                is_array_element variants "${__verify_variants_and_ranges_parsed_[$name]}" ||
                {
                    # Enable word splitting to properly parse '*_stringifier_*' value
                    localize_word_splitting
                    enable_word_splitting
                    # Log error
                    log_error \
                        "Argument '$($__verify_variants_and_ranges_stringifier_ $__verify_variants_and_ranges_definitions_ $name)' " \
                        "parsed with value (${__verify_variants_and_ranges_parsed_[$name]}) when one of" \
                        "{ ${__verify_variants_and_ranges_variants_[$name]} } is required"
                    # Return error
                    return 2
                }

            # Else, if range is defined for the option
            elif is_var_set_non_empty range_str; then

                # Limits of the valid range
                local min
                local max
                # Parse variants
                parse_range                                \
                    "$range_str"                           \
                    "${__verify_variants_and_ranges_raw_}" \
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

                    # Enable word splitting to properly parse '*_stringifier_*' value
                    localize_word_splitting
                    enable_word_splitting
                    # Log error
                    log_error \
                        "Argument '$($__verify_variants_and_ranges_stringifier_ $__verify_variants_and_ranges_definitions_ $name)' " \
                        "parsed with value (${__verify_variants_and_ranges_parsed_[$name]}) when it is limited to ( $min : $max ) range"
                    # Return error
                    return $ret_

                fi
            fi
            
        fi
    done

    return 0
}

# ================================================================================================================================== #
