#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 2:37:47 pm
# @modified Sunday, 14th November 2021 6:19:11 pm
# @project  bash-utils
# @brief
#    
#    Main file of the "parseargs" module
#
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Function ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Parses comand line arguments in an extensive way
#
# @param args 
#    name of the array holding list of arguments to be parsed
# @param pargs (out)
#    name of the 'pargs' array where the parsed positional arguments should be placed
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 when `--help|-h` option has been parsed (if an appropriate option
#       switch passed)
#
# @description
#
#     For extended description of the `parseargs` function refer to the @description
#     of this file and to the given @examples
#
# @options (core)
#
#  -a HARR, --args-definitions=HARR  name of the 'args-definitions' UBAD list
#  -o HARR, --opts-definitions=HARR  name of the 'opts-definitions' UBAD list
#  -e HARR, --envs-definitions=HARR  name of the 'args-definitions' UBAD list
# 
#  -g INT,            --arg-num=INT  required number of positional arguments
#  -m INT,        --arg-num-min=INT  minimal number  of positional arguments 
#                                    (overwritten by --arg-num)
#  -x INT,        --arg-num-max=INT  maximal number  of positional arguments 
#                                    (overwritten by --arg-num)
#  
#  -n HARR,            --nargs=HARR  name of the 'nargs' hash array
#  -u ARR,              --uargs=ARR  name of the 'uargs' array
#  -p HARR,             --opts=HARR  name of the 'opts' hash array
#  -i HARR,             --envs=HARR  name of the 'envs' hash array
#  
# @options (script-oriented)
# 
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails; also 
#                                    printing of the 'usage' message will be handled 
#                                    automatically if the '-h|--help' option will be
#                                    parsed and the usage string is defined
#  -h STR,         --with-usage=STR  usage string to be printed when the --verbose 
#                                    switch is set
#  -u,            --with-auto-usage  if set, the automatic usage message will be 
#                                    printed, when the --verbose switch is set 
#                                    (overwritten by the --with-usage option)
#  -d STR,   --with-description=STR  description string to be printed in the usage 
#                                    string
#  -m STR,      --with-cmd-name=STR  name of the command to be printed in the usage
#                                    message (default: $0)
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
#                                    undefined in 'opts' or 'envs' hash array 
#                                    respecitvely
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
function parseargs() {

    # Arguments
    local __parseargs_args_
    local __parseargs_pargs_

    # Options' definitions
    local -A          __args_definitions_parseargs_opt_def_=( [format]="-a|--args-definitions"          [name]="args_definitions"          [type]="s" )
    local -A          __opts_definitions_parseargs_opt_def_=( [format]="-o|--opts-definitions"          [name]="opts_definitions"          [type]="s" )
    local -A          __envs_definitions_parseargs_opt_def_=( [format]="-e|--envs-definitions"          [name]="envs_definitions"          [type]="s" )
    local -A                   __arg_num_parseargs_opt_def_=( [format]="-g|--arg-num"                   [name]="arg_num"                   [type]="i" )
    local -A               __arg_num_min_parseargs_opt_def_=( [format]="-m|--arg-num-min"               [name]="arg_num_min"               [type]="i" )
    local -A               __arg_num_max_parseargs_opt_def_=( [format]="-x|--arg-num-max"               [name]="arg_num_max"               [type]="i" )
    local -A                     __nargs_parseargs_opt_def_=( [format]="-n|--nargs"                     [name]="nargs"                     [type]="s" )
    local -A                     __uarga_parseargs_opt_def_=( [format]="-u|--uarga"                     [name]="uargs"                     [type]="s" )
    local -A                      __opts_parseargs_opt_def_=( [format]="-p|--opts"                      [name]="opts"                      [type]="s" )
    local -A                      __envs_parseargs_opt_def_=( [format]="-i|--envs"                      [name]="envs"                      [type]="s" )
    local -A                   __verbose_parseargs_opt_def_=( [format]="-v|--verbose"                   [name]="verbose"                   [type]="f" )
    local -A                __with_usage_parseargs_opt_def_=( [format]="-h|--with-usage"                [name]="with_usage"                [type]="s" )
    local -A           __with_auto_usage_parseargs_opt_def_=( [format]="-u|--with-auto-usage"           [name]="with_auto_usage"           [type]="f" )
    local -A          __with_description_parseargs_opt_def_=( [format]="-d|--with-description"          [name]="with_description"          [type]="s" )
    local -A             __with_cmd_name_parseargs_opt_def_=( [format]="-m|--with-cmd-name"             [name]="with_cmd_name"             [type]="s" )
    local -A                       __raw_parseargs_opt_def_=( [format]="-r|--raw"                       [name]="raw"                       [type]="f" )
    local -A            __strict_env_def_parseargs_opt_def_=( [format]="-s|--strict-env-def"            [name]="strict_env_def"            [type]="f" )
    local -A    __flag_default_undefined_parseargs_opt_def_=( [format]="-f|--flag-default-undefined"    [name]="flag_default_undefined"    [type]="f" )
    local -A  __without_int_verification_parseargs_opt_def_=( [format]="-c|--without-int-verification"  [name]="without_int_verification"  [type]="f" )
    local -A __without_path_verification_parseargs_opt_def_=( [format]="-t|--without-path-verification" [name]="without_path_verification" [type]="f" )

    # UBAD list for options
    local -a __parseargs_opts_definitions_=(
        __args_definitions_parseargs_opt_def_
        __opts_definitions_parseargs_opt_def_
        __envs_definitions_parseargs_opt_def_
        __arg_num_parseargs_opt_def_
        __arg_num_min_parseargs_opt_def_
        __arg_num_max_parseargs_opt_def_
        __nargs_parseargs_opt_def_
        __uarga_parseargs_opt_def_
        __opts_parseargs_opt_def_
        __envs_parseargs_opt_def_
        __verbose_parseargs_opt_def_
        __with_usage_parseargs_opt_def_
        __with_auto_usage_parseargs_opt_def_
        __with_description_parseargs_opt_def_
        __with_cmd_name_parseargs_opt_def_
        __raw_parseargs_opt_def_
        __stric_env_def_parseargs_opt_def_
        __flag_default_undefined_parseargs_opt_def_
        __without_int_verification_parseargs_opt_def_
        __without_path_verification_parseargs_opt_def_
    )

}

