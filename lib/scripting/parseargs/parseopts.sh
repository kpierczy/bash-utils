#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Monday, 14th February 2022 10:08:45 pm
# @project  bash-utils
# @brief
#    
#    Options-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses list of arguments named @p args based on the @p opts_definitions UBAD
#    list. Writes parse options to the hash array named @p opts and parsed positional
#    arguments into the array named @p pargs
#
#
# @param args
#    name of the array holding arguments to be parsed
# @param opts_definitions
#    name of the UBAD list array holding options' definitions
# @param opts [out]
#    name of the hash array where the parsed options will be written into
# @param pargs [out]
#    name of the array where the parsed positional arguments will be written into
#
# @returns 
#    @c 0 on success \n
#    @c 1 if function sufferred from the bug \n
#    @c 2 if invalid option has been passed \n
#    @c 3 if argument(s) of the wrong type has been given \n
#    @c 4 if invalid UBAD list has been given
#    @c 5 if '-h|--help' option has been parsed \n
#
# @options (script-oriented)
# 
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails
#  -r,                        --raw  by default, elements of the [variants] and 
#                                    [range] lists of the UBAD table are trimmed
#                                    after being parsed (edge whitespace characters 
#                                    are removed). If this flag is setl this behaviour
#                                    is suspended
#  -f,     --flag-default-undefined  by default, flag arguments are set to 1 when not 
#                                    parsed (in bash '0' means true and '1' means false)
#                                    and set to 0 when parsed. If this flag is set, 
#                                    the non-parsed flag-typed arguments will stay
#                                    undefined in 'opts' hash array 
#  -c,   --without-int-verification  if set, no integer-typed arguments validation is
#                                    performed
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# ---------------------------------------------------------------------------------------
function parseopts() {

    # ---------------------------- Define options -----------------------------

    # Options' definitions
    local -A                   __verbose_parseopts_own_opt_def_=( [format]="-v|--verbose"                  [name]="verbose"                   [type]="f" )
    local -A                       __raw_parseopts_own_opt_def_=( [format]="-r|--raw"                      [name]="raw"                       [type]="f" )
    local -A    __flag_default_undefined_parseopts_own_opt_def_=( [format]="-f|--flag-default-undefined"   [name]="flag_default_undefined"    [type]="f" )
    local -A  __without_int_verification_parseopts_own_opt_def_=( [format]="-c|--without-int-verification" [name]="without_int_verification"  [type]="f" )

    # UBAD list for options
    local -a __parseopts_own_opts_definitions_=(
        __verbose_parseopts_own_opt_def_
        __raw_parseopts_own_opt_def_
        __flag_default_undefined_parseopts_own_opt_def_
        __without_int_verification_parseopts_own_opt_def_
    )

    # -------------------------- Parse own options ----------------------------

    # Create hash array holding own options parsed
    local -a __parseopts_own_args_=( "$@" )
    # Create hash array holding own options parsed
    local -A __parseopts_own_options_
    # Create hash array holding own options parsed
    local -a __parseopts_own_posargs_

    # Parse own options
    parseopts_parseopts          \
        __parseopts_own_args_    \
        __parseopts_own_options_ \
        __parseopts_own_posargs_ ||
    {
        return $?
    }

    # Get positional arguments
    local __parseopts_args_="${__parseopts_own_posargs_[0]:-}"
    local __parseopts_opts_definitions_="${__parseopts_own_posargs_[1]:-}"
    local __parseopts_opts_="${__parseopts_own_posargs_[2]:-}"
    local __parseopts_pargs_="${__parseopts_own_posargs_[3]:-}"

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_ubad_list "$__parseopts_opts_definitions_" 'opts' || return 3
    # Check if arguments of a valid type has been given
    is_array "$__parseopts_args_"      || return 1
    is_hash_array "$__parseopts_opts_" || return 1
    is_array "$__parseopts_pargs_"     || return 1

    # ------------------------- Parse own arguments ---------------------------

    local -n __parseopts_args_="${__parseopts_args_}"
    local -n __parseopts_opts_definitions_="${__parseopts_opts_definitions_}"
    local -n __parseopts_opts_="${__parseopts_opts_}"
    local -n __parseopts_pargs_="${__parseopts_pargs_}"
    
    # =========================================================================

    return 0
}
