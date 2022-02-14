#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts_early.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified Monday, 14th February 2022 10:07:00 pm
# @project  bash-utils
# @brief
#    
#    Simplified version of the @fun parseopts` function aimed to be used by the @fun parseopts itself
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

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
    is_hash_array "$__pode_names_" || return 2
    is_hash_array "$__pode_types_" || return 2
    
    # ---------------------------- Parse arguments ----------------------------

    local -n __pode_opts_definitions_="$1"
    local -n __pode_names_="$2"
    local -n __pode_types_="$3"

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

                # Write variables name corresponding to the option's short/long name
                __pode_names_["$__pode_opt_format_"]="${__pode_opt_ubad_table_[name]}"
                __pode_types_["$__pode_opt_format_"]="${__pode_opt_ubad_table_[type]}"
                
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

    local -n __pgse_types_="$1"
    local -n __pgse_shorts_="$2"
    local -n __pgse_longs_="$3"

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
        return 1   
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

    # A string reporting a library bug
    local __parseopts_bug_msg_=$(echo \
         "A @fun parseopts failed to parse it's own options. This is a library bug. Please" \
         "report it to the librarie's author."
    )
    # Context string for bug messages of the 
    local __parseopts_bug_context_="parseopts"
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
        local LOG_CONTEXT="$__parseopts_bug_context_"
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
        local LOG_CONTEXT="$__parseopts_bug_context_"
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
        local LOG_CONTEXT="$__parseopts_bug_context_"
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
        # Set corresponding key to '1' just to make it defined - the value itself will not be used
        __parseopts_parseopts_own_options_["${__parseopts_own_options_opt_name_}"]="1"

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
