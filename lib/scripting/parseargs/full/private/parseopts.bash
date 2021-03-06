#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified Tuesday, 22nd February 2022 9:23:59 pm
# @project  bash-utils
# @brief
#    
#    Set of functions used to implement 'parseopts'
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================
    
# UBAD table of the auto-generated 'help' option
declare -A __help_parseopts_opt_def_=( [format]="-h|--help" [name]="help" [type]="f" [help]="shows this usage text")

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
#    @retval @c 0 if @p string is a short option 
#    @retval @c 1 otheriwse
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
#    @retval @c 0 if @p string is a long option 
#    @retval @c 1 otheriwse
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
#    @retval @c 0 if @p string is an option 
#    @retval @c 1 otheriwse
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

# ---------------------------------------------------------------------------------------
# @brief Based on the list of arguments and options' definitions finds format of the
#    option corresponding to it's name defined in the UBAD table
#
# @params args
#    name of the list of arguments to be parsed
# @params opt_defs
#    list of valid options' definitions
# @param opt_name
#    name of the option to be matched
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 either if the option corresponding to the @p key
#       was not declared in the @p defs list or it does not
#       appear on the @p args list
#
# @note Function returns format of the the last occurrence of the option in the 
#    @p args list
# ---------------------------------------------------------------------------------------
function get_option_format() {

    # Arguments
    local -n __get_option_format_args_="$1"
    local -n __get_option_format_defs_="$2"
    local  __get_option_format_name_="$3"

    local opt_def=""

    # Search a list of definitions to find name(s) corresponding to the given key
    for opt_def in "${__get_option_format_defs_[@]}"; do

        # Get reference to the UBAD table
        local -n opt_def_ref="$opt_def"

        # If requred table has been found, break
        if [[ "${opt_def_ref[name]}" == "$__get_option_format_name_" ]]; then
            break
        fi

    done

    # Get reference to the UBAD table
    local -n opt_def_ref="$opt_def"
    # If name was not found on the list of definitions, return error
    if [[ "${opt_def_ref[name]}" != "$__get_option_format_name_" ]]; then
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

    local i
    
    # Iterate list of arguments backward to find the last occurence of the option
    for ((i = ${#__get_option_format_args_[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local single_arg="${__get_option_format_args_[$i]}"
        
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


# ---------------------------------------------------------------------------------------
# @brief Extends UBAD list describing option arguments with auto-generated descriptor
#    of the 'help' option if one is not defined yet
#
# @param opt_defs
#    name of the UBAd list containing definitions of options
# ---------------------------------------------------------------------------------------
function autogenerate_help_option() {

    # Parse arguments
    local __autogenerate_help_option_opt_defs_="$1"

    # If descriptor is NOT already defined, add one
    if ! has_ubad_list_table_with_name "$__autogenerate_help_option_opt_defs_" 'help'; then

        # Get reference to the list
        local -n __autogenerate_help_option_opt_defs_ref_="$__autogenerate_help_option_opt_defs_"
        # Append auto-generated help
        __autogenerate_help_option_opt_defs_ref_+=(__help_parseopts_opt_def_)
        
    fi
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
#    @retval @c 0 on success 
#    @retval @c 1 if arguments of invalid type given 
#    @retval @c 2 if @p opts_definitions is not a valid UBAD options' list
# ---------------------------------------------------------------------------------------
function parse_ubad_options_list_core_info () {

    # Arguments
    local __pode_opts_definitions_="${1:-}"
    local __pode_names_="${2:-}"
    local __pode_types_="${3:-}"

    # ------------------------- Validate arguments ----------------------------

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
#    @retval @c 0 on success 
#    @retval @c 1 if arguments of invalid type given 
#    @retval @c 2 if @p types hash array is of invalid format
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
#    @retval @c 0 on success 
#    @retval @c 1 if invalid arguments were passed 
#    @retval @c 2 on parsing error
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
#    parsed-flags definition mode (either 'defined' or 'undefined')
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
#    @retval @c 0 on success 
#    @retval @c 1 if function sufferred from the bug 
#    @retval @c 2 if invalid option has been passed 
#    @retval @c 4 if invalid UBAD list has been given
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function (i.e. `parseargs`)
# ---------------------------------------------------------------------------------------
function parseopts_parse_options() {

    # Parse arguments
    local    __parseopts_parse_options_opts_definitions_="$1"
    local    __parseopts_parse_options_args_="$2"
    local    __parseopts_parse_options_flag_def_type_="$3"
    local -n __parseopts_parse_options_opts_types_="$4"
    local -n __parseopts_parse_options_opts_="$5"
    local -n __parseopts_parse_options_pargs_="$6"

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
        
        # Write all values of the `names_raw` array into `names` array (some names may be repeated as it may be tied to many formats)
        local __parseopts_parse_options_opts_names_=( "${__parseopts_parse_options_opts_names_raw_[@]}" )
    
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
#    @retval @c 0 on success 
#    @retval @c 1 if function sufferred from the bug 
#    @retval @c 2 if invalid option has been passed 
# ---------------------------------------------------------------------------------------
function parseopts_parseopts() {

    # Parse arguments
    local __parseopts_parseopts_own_args_="$1"
    local -n __parseopts_parseopts_own_options_="$2"
    local -n __parseopts_parseopts_own_posargs_="$3"
    
    # Clear output arrays
    __parseopts_parseopts_own_options_=()
    __parseopts_parseopts_own_posargs_=()

    # ----------------------- Parse core informations -------------------------

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

    # ------------------------ Compile getopt request -------------------------

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

    local ret_

    # ------------------------------ Run getopt -------------------------------

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

    # ------------------------- Parse getopt results --------------------------

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

    # -------------------------------------------------------------------------

    return 0
}

# ========================================================= Help formatter ========================================================= #

# ---------------------------------------------------------------------------------------
# @brief Automatically generates description of option arguments based on the UBAD list
#
# @param opt_defs
#    name of the UBAD list containing option arguments' definitions
# @param parse_mode ( optional, default: 'default' )
#    parse mode (either 'default' - list element's will be trimmed - or 'raw' - list 
#    element's will NOT be trimmed)
# @param with_auto_help ( optional, default: '' )
#    if given as 'with_auto_help', the automatically-generated [help] option will
#    be added to definitions (is one is not already defined)
# ---------------------------------------------------------------------------------------
function generate_opts_description() {   

    # Parse arguments
    local __generate_opts_description_opt_defs_="$1"
    local __generate_opts_description_parse_mode_="${2:-default}"
    local __generate_opts_description_with_auto_help_="${3:-}"

    # Get reference to the UBAD list
    local -n __generate_opts_description_opt_defs_ref_="$__generate_opts_description_opt_defs_"

    # ---------------------- Add optional 'help' option -----------------------

    # If option enabled, append table
    if [[ "$__generate_opts_description_with_auto_help_" == "with_auto_help" ]]; then

        # Check if list already contains 'help' option
        if ! has_ubad_list_table_with_name "$__generate_opts_description_opt_defs_" 'help'; then

            # Create local copy of the UBAD list that the additional table will appended into
            local -a __generate_opts_description_opt_defs_copy_=( "${__generate_opts_description_opt_defs_ref_[@]}" )
            # Append auto-generated help
            __generate_opts_description_opt_defs_copy_+=(__help_parseopts_opt_def_)
            # Change reference to the local copy
            local -n __generate_opts_description_opt_defs_ref_=__generate_opts_description_opt_defs_copy_
            
        fi

    fi

    # ------------------------ Format the description -------------------------
    
    # Prepare outpt hash array for formats
    local -A formats=()
    # Prepare outpt hash array for helps
    local -A helps=()
    # Prepare outpt hash array for types
    local -A types=()
    
    local opt_def=""

    # Parse formats and helps
    parse_description_info                         \
        __generate_opts_description_opt_defs_ref_  \
        "$__generate_opts_description_parse_mode_" \
        formats helps types

    local name
    
    # Iterate over formats and reformat them into prettier form
    for name in "${!formats[@]}"; do
    
        # Get format of the option
        local format="${formats[$name]}"
        # Get format's string
        local type_string="$(ubad_arg_type_usage_string ${types[$name]})"
        
        # Replace '|' delimiters with ', '
        format="${format//|/, }"
        # Add type strings to options
        if ! is_ubad_arg_flag ${types[$name]}; then
            
            local short_pattern_middle='(.*)-([[:alpha:]]),(.*)'
            local long_pattern_middle='(.*)--([-[:alpha:]]+),(.*)'

            # Cover options in the middle of the string (delimited with comma) [long options]
            while [[ "$format" =~ $long_pattern_middle ]]; do
                format="${BASH_REMATCH[1]}--${BASH_REMATCH[2]}=<$type_string>,${BASH_REMATCH[3]}"
            done
            # Cover options in the middle of the string (delimited with comma) [short options]
            while [[ "$format" =~ $short_pattern_middle ]]; do
                format="${BASH_REMATCH[1]}-${BASH_REMATCH[2]} <$type_string>,${BASH_REMATCH[3]}"
            done

            # Cover options on the end of the string
            local short_pattern_end='(.*)-([[:alpha:]])$'
            local long_pattern_end='(.*)--([-[:alpha:]]+)$'

            # Cover options on the end of the string [long options]
            while [[ "$format" =~ $long_pattern_end ]]; do
                format="${BASH_REMATCH[1]}--${BASH_REMATCH[2]}=<$type_string>"
            done
            # Cover options on the end of the string [short options]
            while [[ "$format" =~ $short_pattern_end ]]; do
                format="${BASH_REMATCH[1]}-${BASH_REMATCH[2]} <$type_string>"
            done
        
        fi
        
        # Keep reformatted string
        formats["$name"]="$format"

    done

    # Compile description text
    compile_description_info formats helps

    # -------------------------------------------------------------------------
}

# ================================================================================================================================== #
