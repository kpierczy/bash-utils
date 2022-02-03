#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseenvs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Sunday, 14th November 2021 12:45:58 pm
# @project  bash-utils
# @brief
#    
#    Environmental-arguments-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses environment based on the @p envs_definitions UBAD list. Writes parse
#    options to the hash array named @p opts and parsed positional arguments into the
#    array named @p envs
#
# @param envs_definitions
#    name of the UBAD list array holding environmental arguments' definitions
# @param envs (out)
#    name of the hash array where the parsed options will be written into
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error
#
# @options (script-oriented)
# 
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails
#
# @options (minor)
# 
#  -r,                        --raw  by default, elements of the [variants] and 
#                                    [range] lists of the UBAD table are trimmed
#                                    after being parsed (edge whitespace characters 
#                                    are removed). If this flag is setl this behaviour
#                                    is suspended
#  -s,             --strict-env-def  by default, if the environmental argument with
#                                    the defined [format] is set but does not meet
#                                    requirements descibed in the UBAD table, function
#                                    will assume that the variable comes from the upper
#                                    context and was not intended to be an argument
#                                    of the function/script whose arguments are parsed
#                                    by the `parseargs`. In such case, the argument will
#                                    be considered not-parsed; if this switch is set,
#                                    the environmental argument that is set, but does
#                                    not meet requirements will be considered erronous
#                                    and the 1 status code will be returned by the 
#                                    `parseargs`
#  -f,     --flag-default-undefined  by default, flag arguments are set to 1 when not 
#                                    parsed (in bash '0' means true and '1' means false)
#                                    and set to 0 when parsed. If this flag is set, 
#                                    the non-parsed flag-typed arguments will stay
#                                    undefined in 'envs' hash array 
#  -c,   --without-int-verification  if set, no integer-typed arguments validation is
#                                    performed
#  -t,  --without-path-verification  if set, no path-typed arguments validation is
#                                    performed
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# ---------------------------------------------------------------------------------------
function parseenvs() {
    
    # Arguments
    local __parseenvs_envs_definitions_
    local __parseenvs_envs_

    # Options' definitions
    local -A                   __verbose_parseenvs_opt_def_=( [format]="-v|--verbose"                   [name]="verbose"                   [type]="f" )
    local -A                       __raw_parseenvs_opt_def_=( [format]="-r|--raw"                       [name]="raw"                       [type]="f" )
    local -A            __strict_env_def_parseenvs_opt_def_=( [format]="-s|--strict-env-def"            [name]="strict_env_def"            [type]="f" )
    local -A    __flag_default_undefined_parseenvs_opt_def_=( [format]="-f|--flag-default-undefined"    [name]="flag_default_undefined"    [type]="f" )
    local -A  __without_int_verification_parseenvs_opt_def_=( [format]="-c|--without-int-verification"  [name]="without_int_verification"  [type]="f" )
    local -A __without_path_verification_parseenvs_opt_def_=( [format]="-t|--without-path-verification" [name]="without_path_verification" [type]="f" )

    # UBAD list for options
    local -a __parseenvs_opts_definitions_=(
                          __verbose_parseenvs_opt_def_
                              __raw_parseenvs_opt_def_
                   __strict_env_def_parseenvs_opt_def_
           __flag_default_undefined_parseenvs_opt_def_
         __without_int_verification_parseenvs_opt_def_
        __without_path_verification_parseenvs_opt_def_
    )

}