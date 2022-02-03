#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts_early.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified Sunday, 14th November 2021 9:26:18 pm
# @project  bash-utils
# @brief
#    
#    Simplified version of the @fun parseopts` function aimed to be used by the @fun parseopts itself
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

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
function parse_ubad_options_list () {

    # Arguments
    local __pode_opts_definitions_="${1:-}"
    local __pode_names_="${2:-}"
    local __pode_types_="${3:-}"

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_ubad_options_list "$__pode_opts_definitions_" || return 2
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

        # Iterate over all options definitions
        for __pode_opt_formats_ in "${!__pode_opt_def_[format]}"; do
        
            # Set world-splitting-separator to ' ' + '|' automaticaly parse option's names
            IFS='|'
            # Set positional arguments to the option's names
            set -- $__pode_opt_formats_

            # A single option's format
            local __pode_opt_format_

            # Iterate option's formats
            for __pode_opt_format_ in "$@"; do

                # Write variables name corresponding to the option's short/long name
                __pode_names_["$__pode_opt_format_"]="${!__pode_opt_def_[name]}"
                __pode_types_["$__pode_opt_format_"]="${!__pode_opt_def_[type]}"
                
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
    local -n __pgse_types_="${1:-}"
    local -n __pgse_shorts_="${2:-}"
    local -n __pgse_longs_="${3:-}"

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_hash_array "$__pgse_types_" || return 1
    # Check if arguments of a valid type has been given
    is_hash_array "$__pgse_shorts_" || return 1
    is_hash_array "$__pgse_longs_" || return 1
    
    # ---------------------------- Parse arguments ----------------------------

    local -n __pgse_types_="$1"
    local -n __pgse_shorts_="$2"
    local -n __pgse_longs_="$3"

    # -------------------------------------------------------------------------

    # Cleanup output strings
    __pgse_shorts_=""
    __pgse_longs_=""

    local __pgse_opt_format_

    # Iterate over options' formats
    for __pgse_opt_format_ in "${!__pode_opts_definitions_[@]}"; do

        # Chec if a valid option format given
        is_option "$__pgse_opt_format_" || return 2
        # If so, check if a valid argument's type given
        is_ubad_arg_type "${!__pgse_types_[$__pgse_opt_format_]}" || return 2

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
        case "${!__pgse_types_[$__pgse_opt_format_]}" in
            "f" | "flag" )                           ;;
            *            ) __pgse_out_string_+=": "  ;;
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
#    string holding comma-separated list of short options to be parsed
# @param long
#    string representing comma-separated list of long options to be parsed
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

# ---------------------------------------------------------------------------------------
# @brief Parses @p getopt_output string produced by the `getopt` utility. 
# ---------------------------------------------------------------------------------------