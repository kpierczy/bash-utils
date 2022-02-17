#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts_early.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified Thursday, 17th February 2022 8:18:38 pm
# @project  bash-utils
# @brief
#    
#    Simplified version of the @fun parseopts` function aimed to be used by the @fun parseopts itself
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# A string reporting a library bug
declare __parseopts_bug_msg_=$(echo \
        "A @fun parseopts failed to parse it's own options. This is a library bug. Please" \
        "report it to the librarie's author."
)

# ============================================================= Helpers ============================================================ #

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a short option (in sense
#    of the `getopt` tool, i.e. if it is a letter with a single
#    leading dash)
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is a short option \n
#    @c 1 otheriwse
# -------------------------------------------------------------------
function is_short_option() {

    # Arguments
    local string_="$1"

    # Check if a short option
    [[ ${#string_} == "2" ]] &&
    [[ ${string_:0:1} == "-" ]] &&
    [[ ${string_:1:1} =~ [[:alpha:]] ]] ||
    # If not, return error
    return 1

    # If a valid short option, return success
    return 0

}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a long option (in sense
#    of the `getopt` tool, i.e. if it is a non-empty string with 
#    a double leading dash)
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is a long option \n
#    @c 1 otheriwse
# -------------------------------------------------------------------
function is_long_option() {

    # Arguments
    local string_="$1"

    # Check if a long option
    starts_with "$string_ " "--" && 
    [[ ${string_:2} =~ [[:alpha:]-]+ ]] ||
    # If not, return error
    return 1

    # If a valid long option, return success
    return 0

}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a short or a long option
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is an option \n
#    @c 1 otheriwse
#
# @see is_short_option
# @see is_long_option
# -------------------------------------------------------------------
function is_option() {

    # Arguments
    local string_="$1"

    # Check if an option
    is_short_option "$string_" || is_long_option "$string_"

}

# -------------------------------------------------------------------
# @brief Based on the list of arguments and options' definitions
#    finds name of the option corresponding to the name of the
#    key in the @p options hash table returned by the @fun parseopts_s
#    function. Nameis written to the stdout
#
# @params args
#    name of the list of arguments to be parsed
# @params opt_defs
#    list of valid options' definitions
# @param opt_name
#    name of the option to be matched
#
# @returns 
#    @c 0 on success \n
#    @c 1 either if the option corresponding to the @p key
#       was not declared in the @p defs list or it does not
#       appear on the @p args list
#
# @note Function returns format of the the last occurrence of the 
#    option in the @p args list
# -------------------------------------------------------------------
function get_option_format() {

    # Arguments
    local -n __get_option_name_args_="$1"
    local -n __get_option_name_defs_="$2"
    local  __get_option_name_name_="$3"

    # Local iterator
    local opt_def=""

    # Search a list of definitions to find name(s) corresponding to the given key
    for opt_def in "${__get_option_name_defs_[@]}"; do

        # Get reference to the UBAD table
        local -n opt_def_ref="$opt_def"

        # If requred table has been found, break
        if [[ "${opt_def_ref[name]}" == "$__get_option_name_name_" ]]; then
            break
        fi

    done

    # Get reference to the UBAD table
    local -n opt_def_ref="$opt_def"
    # If name was not found on the list of definitions, return error
    if [[ "${opt_def_ref[name]}" != "$__get_option_name_name_" ]]; then
        return 1
    fi

    # Set world-splitting separator to comma to extract option's format
    localize_word_splitting
    push_stack "$IFS"
    IFS='|'
    # Set positional arguments to the conent of @var defn (@notice auto word-splitting)
    set -- ${opt_def_ref[format]}
    # Restor the prevous word-splitting separator
    pop_stack IFS
    # Get list of format from positional arguments
    local -a format_list=( "$@" )

    # Iterate list of arguments backward to find the last occurence of the option
    for ((i = ${#__get_option_name_args_[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local single_arg="${__get_option_name_args_[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        starts_with "${single_arg}" "-" || continue

        local opt_format

        # Iterate over names of the searched option
        for opt_format in "${format_list[@]}"; do
            
            # If name matches one of the names of the searched option, exit function as success
            starts_with "$single_arg" "$opt_format" && {

                echo "$opt_format"
                return 0
            }

        done

    done

    # If no option found, return error
    return 1
}

# ========================================================= Implementations ======================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses @p opts_definitions UBAD list of options' UBAD tables into the two hash
#    arrays named @p name and @p type which relate option's format with it's name and
#    type accordingly.
#
# @param opts_definitions
#    name of the UBAD list holding definitions of the options (@see parseopts)
# @param names [out]
#    output hash array asosiating option's format with it's name
# @param types [out]
#    output hash array asosiating option's format with it's type
#
# @returns
#    @c 0 on success \n
#    @c 1 if arguments of invalid type given \n
#    @c 2 if @p opts_definitions is not a valid UBAD options' list
# ---------------------------------------------------------------------------------------
function parse_ubad_options_list_core_info () {

    # Arguments
    local __pode_opts_definitions_="${1:-}"
    local __pode_names_="${2:-}"
    local __pode_types_="${3:-}"

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_ubad_list "$__pode_opts_definitions_" 'opts' || return 2
    # Check if arguments of a valid type has been given
    is_hash_array "$__pode_names_" || return 1
    is_hash_array "$__pode_types_" || return 1
    
    # ---------------------------- Parse arguments ----------------------------

    local -n __pode_opts_definitions_="$__pode_opts_definitions_"
    local -n __pode_names_="$__pode_names_"
    local -n __pode_types_="$__pode_types_"

    # --------------------------------------------------------------

    # Cleanup output arrays
    __pode_names_=()
    __pode_types_=()

    # Limit modifications of the IFS word-splitter to the local scope
    local IFS=$IFS

    # Single UBAD table
    local __pode_opt_def_

    # Iterate over UBAD tables
    for __pode_opt_def_ in "${__pode_opts_definitions_[@]}"; do
    
        # |-separated list of option's formats
        local __pode_opt_formats_

        # Get reference to the UBAD table
        local -n __pode_opt_ubad_table_="$__pode_opt_def_"

        # Iterate over all options definitions
        for __pode_opt_formats_ in "${__pode_opt_ubad_table_[format]}"; do

            # Set world-splitting-separator to ' ' + '|' automaticaly parse option's names
            IFS='|'
            # Set positional arguments to the option's names
            set -- $__pode_opt_formats_

            # A single option's format
            local __pode_opt_format_

            # Iterate option's formats
            for __pode_opt_format_ in "$@"; do

                # Write option's name
                __pode_names_["$__pode_opt_format_"]="${__pode_opt_ubad_table_[name]}"
                # Write option's type (default is string)
                if is_var_set __pode_opt_ubad_table_[type]; then
                    __pode_types_["$__pode_opt_format_"]="${__pode_opt_ubad_table_[type]}"
                else
                    __pode_types_["$__pode_opt_format_"]="s"
                fi
                
            done
            
        done

    done

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Based on the hash array named @p types pairing an option's format with it's
#    type produces two strings representing set of long and set of short options in the 
#    format taken by `getopt` utility 
#
# @param types 
#    name of the hash array relating option's name to it's type; this array is produced
#    by the @fun parse_opts_definitions_early
# @param shorts [out]
#    name of the variable that the resulting definitions of the short options will be
#    written into
# @param longs [out]
#    name of the variable that the resulting definitions of the long options will be 
#    written into
#
# @returns
#    @c 0 on success \n
#    @c 1 if arguments of invalid type given \n
#    @c 2 if @p types hash array is of invalid format
# ---------------------------------------------------------------------------------------
function compile_getopt_definitions() {

    # Arguments
    local __pgse_types_="${1:-}"
    local __pgse_shorts_="${2:-}"
    local __pgse_longs_="${3:-}"

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_hash_array "$__pgse_types_" || return 1
    
    # ---------------------------- Parse arguments ----------------------------

    local -n __pgse_types_="$__pgse_types_"
    local -n __pgse_shorts_="$__pgse_shorts_"
    local -n __pgse_longs_="$__pgse_longs_"

    # -------------------------------------------------------------------------

    # Cleanup output strings
    __pgse_shorts_=""
    __pgse_longs_=""

    local __pgse_opt_format_

    # Iterate over options' formats (keys of the __pgse_types_ hash array)
    for __pgse_opt_format_ in "${!__pgse_types_[@]}"; do

        # Check if a valid option format given
        is_option "$__pgse_opt_format_" || return 2
        
        # If so, check if a valid argument's type given
        is_ubad_arg_type "${__pgse_types_[$__pgse_opt_format_]}" || return 2

        # Type of the option parsed
        local __pgse_out_string_ref_

        # Append option's format to the one of getopt's strings (remove -/-- prefix)
        case "$__pgse_opt_format_" in
            -?  ) # Short option
                __pgse_shorts_+=",${__pgse_opt_format_#?}"
                __pgse_out_string_ref_="__pgse_shorts_"
                ;;
            *   ) # Long option
                __pgse_longs_+=",${__pgse_opt_format_#??}"
                __pgse_out_string_ref_="__pgse_longs_"
                ;;
        esac

        local -n __pgse_out_string_="${__pgse_out_string_ref_}"

        # If non-flag option given, append ':' to the option's format
        case "${__pgse_types_[$__pgse_opt_format_]}" in
            "f" | "flag" )                         ;;
            *            ) __pgse_out_string_+=":" ;;
        esac        

    done

    # Remove leading comma from the output strings
    __pgse_shorts_="${__pgse_shorts_#,}"
    __pgse_longs_="${__pgse_longs_#,}"

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Wrapper aroung `getop` utility. Parses arguments given in the array @p args
#    using `getopt` utility. Writes out result of the `getopt` to the stdout.
#
# @param args
#    name of the array holding arguments co be parsed
# @param short
#    name of the string holding comma-separated list of short options to be parsed
# @param long
#    name of the string representing comma-separated list of long options to be parsed
#
# @returns
#    @c 0 on success \n
#    @c 1 if invalid arguments were passed \n
#    @c 2 on parsing error
# ---------------------------------------------------------------------------------------
function wrap_getopt() {

    # Arguments
    local __wg_args_="${1:-}"
    local __wg_short_="${2:-}"
    local __wg_long_="${3:-}"

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_array "$__wg_args_" || return 1

    # ---------------------------- Parse arguments ----------------------------

    local -n __wg_args_="$1"
    local -n __wg_short_="$2"
    local -n __wg_long_="$3"

    # -------------------------------------------------------------------------

    # Output of the `getopt` tool
    local __wg_result_
    # Status code produced by `getopt`
    local __wg_ret_

    # Parse options using getopt
    __wg_result_=$(getopt -o "$__wg_short_" ${__wg_long_:+-l} $__wg_long_ -n $0 -- "${__wg_args_[@]}") && 
        __wg_ret_=$? || __wg_ret_=$?

    # Write out results
    [[ $__wg_ret_ == "0" ]] && 
        echo "$__wg_result_" && return 0 || 
        return 2  
}

# ---------------------------------------------------------------------------------------
# @brief Parses options of ther `parseopts` caller using getops
#
# @param opts_definitions
#    name of the UBAD list containing options' definitions
# @param args
#    name of the list holding caller's arguments to be parsed
# @param flag_def_type
#    verbosity mode (either 'defined' or 'undefined')
# @param opts_names [out]
#    name of the array that the names of the valid options will be parsed into (these
#    names are keys to the values in the @p opts_types and @p opts hash arrays that
#    match given option with it's type/parsed value)
# @param opts_types [out]
#    name of the hash array holding pairs optname-opttype (every name has it's type
#    defined here)
# @param opts [out]
#    name of the hash array holding values of actually parsed options (option's whose
#    names have no defined value inside this array has not been parsed)
# @param pargs [out]
#    name of the array holding values of actually parsed positional arguments
#
# @returns 
#    @c 0 on success \n
#    @c 1 if function sufferred from the bug \n
#    @c 2 if invalid option has been passed \n
#    @c 4 if invalid UBAD list has been given
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function (i.e. `parseargs`)
# ---------------------------------------------------------------------------------------
function parseopts_parse_options() {

    # Parse arguments
    local    __parseopts_parse_options_opts_definitions_="$1"
    local    __parseopts_parse_options_args_="$2"
    local    __parseopts_parse_options_flag_def_type_="$3"
    local -n __parseopts_parse_options_opts_names_="$4"
    local -n __parseopts_parse_options_opts_types_="$5"
    local -n __parseopts_parse_options_opts_="$6"
    local -n __parseopts_parse_options_pargs_="$7"

    # --------------- Parse names and types of valid options ------------------
    
    # A hash array assosiating caller options' formats with their names
    local -A __parseopts_parse_options_opts_names_raw_
    # A hash array assosiating caller options' formats with their types
    local -A __parseopts_parse_options_opts_types_raw_

    # Parse caller options' definitions
    parse_ubad_options_list_core_info                   \
        ${__parseopts_parse_options_opts_definitions_}  \
        __parseopts_parse_options_opts_names_raw_       \
        __parseopts_parse_options_opts_types_raw_       || 
    {
        # If error returned, report bug (should not happen, as __parseopts_opts_definitions_ has been already checked)
        log_error "$__parseopts_bug_msg_"
        return 1
    }

    # -------------------- Parse options using `getopt` -----------------------

    # String with `getopt`-compatibile definitions of caller's short options
    local __parseopts_parse_options_getopt_shorts_
    # String with `getopt`-compatibile definitions of caller's long options
    local __parseopts_parse_options_getopt_longs_

    # Parse @var own_options_types hash array into the format suitable for `getopt` utility
    compile_getopt_definitions                    \
        __parseopts_parse_options_opts_types_raw_ \
        __parseopts_parse_options_getopt_shorts_  \
        __parseopts_parse_options_getopt_longs_   ||
    {
        # If error returned, report 'invalid UBAD list' as the options' formats must have been invalid
        log_error "UBAD list contains invalid 'format' information of some options"
        return 4
    }

    # Parse caller's options with getopt
    local __parseopts_parse_options_getopt_output_=$(
        wrap_getopt                                   \
            ${__parseopts_parse_options_args_}        \
            __parseopts_parse_options_getopt_shorts_  \
            __parseopts_parse_options_getopt_longs_
    ) && __ret_=$? || __ret_=$?
    
    # If 'invalid argument passed' returned, report bug
    if [[ "$__ret_" == "1" ]]; then

        log_error "$__parseopts_bug_msg_"
        return 1

    # If 'parsing error' returned, report error
    elif [[ "$__ret_" == "2" ]]; then

        local -n __parseopts_parse_options_args_ref_="${__parseopts_parse_options_args_}"
        log_error "Failed to parse options from (${__parseopts_parse_options_args_ref_[@]})"
        return 2
        
    fi

    # -------------------- Parse result of the `getopt` -----------------------

    # For convinience, set positional arguments to those parse by `getopt` (own arguments has been already parsed to variables)
    eval "set -- $__parseopts_parse_options_getopt_output_"

    # Iterate over @p args_ as long as an option is seen
    while [[ "${1:-}" == -?* ]]; do
        
        # If '--' met, break
        [[ "$1" == -- ]] && {
            shift
            break
        }
        # If the option passed but not defined, return error
        is_var_set __parseopts_parse_options_opts_names_raw_["$1"] || return 2
        # Else, parse the name and type
        local __parseopts_parse_options_opts_opt_name_="${__parseopts_parse_options_opts_names_raw_[$1]}"
        local __parseopts_parse_options_opts_opt_type_="${__parseopts_parse_options_opts_types_raw_[$1]}"
        # Check type of the parsed argument
        case "${__parseopts_parse_options_opts_opt_type_}" in

            # If flag parsed
            'f' | 'flag' )

                # Set corresponding key to '0'
                __parseopts_parse_options_opts_["${__parseopts_parse_options_opts_opt_name_}"]="0" ;;

            # If any other type parsed
            * )

                # Parse value of the option
                __parseopts_parse_options_opts_["${__parseopts_parse_options_opts_opt_name_}"]="$2"
                # Add additional shift of argument's list to consume option's format (value will be consumed by `shift` on the end of loop)
                shift ;;

        esac

        # Shift to the next arg
        shift

    done
    
    # --------------------- Parse positional arguments ------------------------
    
    # Set positional arguments
    __parseopts_parse_options_pargs_=( "$@" )
    
    # -------- Transform output helper (h)arrays into required form -----------

    # Write all values of the `names_raw` array into `names` array (some names may be repeated as it may be tied to many formats)
    __parseopts_parse_options_opts_names_=( "${__parseopts_parse_options_opts_names_raw_[@]}" )
    # Remove duplicated names (use unordered set convention, as order of names is not importantant)
    array_to_uset __parseopts_parse_options_opts_names_

    local format

    # Iterate over hash array of types
    for format in "${!__parseopts_parse_options_opts_types_raw_[@]}"; do

        # Get name corresponding to the option's format
        local __parseopts_parse_options_opts_opt_name_="${__parseopts_parse_options_opts_names_raw_[$format]}"
        # Get type corresponding to the option's format
        local __parseopts_parse_options_opts_opt_type_="${__parseopts_parse_options_opts_types_raw_[$format]}"
        
        # Match option's name with it's type (in this process duplicates of the same option - resulting from multiple
        # formats matching the same option - will be removed)
        __parseopts_parse_options_opts_types_["$__parseopts_parse_options_opts_opt_name_"]="$__parseopts_parse_options_opts_opt_type_"

    done

    # ---------------- Fill not-parsed flag options with '1' ------------------
    
    # If 'defined flags' mode requested
    if [[ "${__parseopts_parse_options_flag_def_type_}" == "defined" ]]; then
        local opt_name

        # Iterate over all options
        for opt_name in "${__parseopts_parse_options_opts_names_[@]}"; do

            # If option is not parsed, set it to '1'
            if ! is_var_set __parseopts_parse_options_opts_["$opt_name"]; then
                __parseopts_parse_options_opts_["$opt_name"]="1"
            fi

        done

    fi

    # -------------------------------------------------------------------------

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Parses a specific @p field from UBAD tables given in the @p opts_definitions 
#    UBAD list and pairs them with argument's name (skips flag-typed arguments)
#
# @param opts_definitions
#    name of the UBAD list containing options' definitions
# @param field
#    field to be parsed
# @param opts_fields [out]
#    name of the has array that the default values of non-flag options will be written
#    into
#
# @returns 
#    @c 0 on success \n
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function (i.e. `parseargs`)
# ---------------------------------------------------------------------------------------
function parseopts_parse_field() {

    # Parse arguments
    local -n __parseopts_parse_field_opts_definitions_="$1"
    local    __parseopts_parse_field_field_="$2"
    local -n __parseopts_parse_field_opts_fields_="$3"

    # ------------------------- Parse default values --------------------------

    local ubad_table

    # Get the field name
    local field="${__parseopts_parse_field_field_}"

    # Iterate over UBAD list
    for ubad_table in "${__parseopts_parse_field_opts_definitions_[@]}"; do
    
        # Get reference to the table
        local -n ubad_table_ref="${ubad_table}"
        
        # If flag option met, continue
        is_var_set ubad_table_ref[type] && is_ubad_arg_flag "${ubad_table_ref[type]}" &&
            continue
        # If default value defined, write it down
        if is_var_set ubad_table_ref["$field"]; then
            
            # Get name of the argument
            local name="${ubad_table_ref[name]}"
            # Get value of the argument
            local value="${ubad_table_ref[$field]}"
            # Write the value down
            __parseopts_parse_field_opts_fields_["$name"]="$value"

        fi

    done

    # -------------------------------------------------------------------------

    return 0   
}

# ---------------------------------------------------------------------------------------
# @brief Automatically generates description of option arguments based on the UBAD list
#
# @param opt_defs
#    name of the UBAD list containing option arguments' definitions
# ---------------------------------------------------------------------------------------
function generate_options_description() {   

    # Parse arguments
    local -n __generate_options_description_opt_defs_="$1"
    
    # Prepare outpt hash array for formats
    local -A formats=()
    # Prepare outpt hash array for helps
    local -A helps=()
    
    local opt_def=""

    # Iterate over defined UBDA tables to gather information about subequent options
    for opt_def in "${__generate_options_description_opt_defs_[@]}"; do
    
        # Get reference to the UBAD table
        local -n opt_def_ref="$opt_def"

        # Get name of the option
        local name="${opt_def_ref[name]}"
        
        # Get format of the option
        local format="${opt_def_ref[format]}"
        # Get help of the option
        local help=""
        is_var_set opt_def_ref[help] && help="${opt_def_ref[help]}"

        # Get format's string
        local type_string="$(ubad_arg_type_usage_string ${opt_def_ref[type]})"

        # Transform and keep format string (add argument type's identifier and replace '|' delimiters with ', ')
        formats["$name"]="${format//|/${type_string}, }${type_string}"
        # Keep help string
        helps["$name"]="$help"

    done

    # Maximal lenght of the optional argument's description
    local OPTION_DESCRIPTION_LENGTH_MAX=85

    local name=""
    
    # Prepare maximum length of the format string
    local -i max_format_length=$(max_len formats)
    # Print full descriptions
    for name in "${!formats[@]}"; do
        
        # Create format string (left-aligned)
        local description=$(printf "%-${max_format_length}s " "${formats[$name]}")
        
        # Enable word splitting (locally)
        localize_word_splitting
        enable_word_splitting

        local word=""

        # Number of characters written in the row
        local chars_in_row
        (( chars_in_row = $max_format_length + 2 ))

        # Loop over words in the description and print them so that it fits in required width
        for word in ${helps[$name]}; do
        
            if (( $chars_in_row + 1 + ${#word} <= $OPTION_DESCRIPTION_LENGTH_MAX )); then

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

    return 0
}

# ========================================================== Bootstraping ========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses options passed to the @fun parseopts function
#
# @param parseopts_own_opts_definitions
#    name of the array holding names of UBAD tables describing options of the 
#    @fun parseopts function
# @param parseopts_own_options [out]
#    name of the hash array that the options of the @fun parseopts function will be 
#    parsed into (present flags will be defined as '1' and non-present ones will have
#    no corresponding keys in the array)
# @param parseopts_own_posargs [out]
#    name of the array that the positional arguments of the @fun parseopts function will 
#    be parsed into
#
# @returns 
#    @c 0 on success \n
#    @c 1 if function sufferred from the bug \n
#    @c 2 if invalid option has been passed \n
# ---------------------------------------------------------------------------------------
function parseopts_parseopts() {

    # Parse arguments
    local __parseopts_parseopts_own_args_="$1"
    local -n __parseopts_parseopts_own_options_="$2"
    local -n __parseopts_parseopts_own_posargs_="$3"
    
    # Clear output arrays
    __parseopts_parseopts_own_options_=()
    __parseopts_parseopts_own_posargs_=()

    # Helper variable used to store status code of commands
    local ret_

    # A hash array assosiating own options' formats with their names
    local -A __parseopts_own_options_names_
    # A hash array assosiating own options' formats with their types
    local -A __parseopts_own_options_types_

    # Parse own options' definitions
    parse_ubad_options_list_core_info     \
        __parseopts_own_opts_definitions_ \
        __parseopts_own_options_names_    \
        __parseopts_own_options_types_   || 
    {
        local code_="$?"
        log_error "$__parseopts_bug_msg_ ($code_)"
        return 1
    }

    # String with `getopt`-compatibile definitions of own short options
    local __parseopts_own_getopt_shorts_
    # String with `getopt`-compatibile definitions of own long options
    local __parseopts_own_getopt_longs_

    # Parse @var own_options_types hash array into the format suitable for `getopt` utility
    compile_getopt_definitions         \
        __parseopts_own_options_types_ \
        __parseopts_own_getopt_shorts_ \
        __parseopts_own_getopt_longs_ ||
    {
        log_error "$__parseopts_bug_msg_"
        return 1
    }

    # Parse own options with getopt
    local __parseopts_own_getopt_output_=$(
        wrap_getopt                            \
            ${__parseopts_parseopts_own_args_} \
            __parseopts_own_getopt_shorts_     \
            __parseopts_own_getopt_longs_
    ) && ret_=$? || ret_=$?

    # Inspect the status cpde
    [[ $ret_ == "1" ]] &&
    {
        log_error "$__parseopts_bug_msg_"
        return 1
    }
    [[ $ret_ == "2" ]] &&
    {
        return 2
    }

    # Set positional arguments to those parse by `getopt`
    eval "set -- $__parseopts_own_getopt_output_"

    # Iterate over @p args_ as long as an option is seen
    while [[ "${1:-}" == -?* ]]; do
        
        # If '--' met, break
        [[ "$1" == -- ]] && {
            shift
            break
        }
        # If the option passed but not defined, return error
        is_var_set __parseopts_own_options_names_["$1"] || return 2
        # Else, parse the name
        local __parseopts_own_options_opt_name_="${__parseopts_own_options_names_[$1]}"
        # Set corresponding key to '0' just to make it defined - the value itself will not be used
        __parseopts_parseopts_own_options_["${__parseopts_own_options_opt_name_}"]="0"

        # ----------------------------------------------------------------------------
        # @note: This loop takes advantage of the prior knowledge of the fact that 
        #    the options taken by the `parseopts` functuon are only flags and it does
        #    not need to check for the type of the currently parsed option
        # ----------------------------------------------------------------------------

        # Shift to the next arg
        shift

    done

    # Set positional arguments
    __parseopts_parseopts_own_posargs_=( "$@" )

    return 0
}

# ================================================================================================================================== #
