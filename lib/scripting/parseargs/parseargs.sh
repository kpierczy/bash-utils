#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 2:37:47 pm
# @modified Saturday, 13th November 2021 8:02:12 pm
# @project  BashUtils
# @brief
#    
#    Main file of the "parseargs" module
#
# @description
#    
#     "parseargs" has been designed to serve as a universal automation tool for parsing arguments in both bash function and bash 
#     script context. It provides a flexible interface that makes it useble in case of a simple a few-lines-long library functions 
#     as well as in the extensive multi-tool scripts requiring automated validation of arguments and automated generation of the 
#     `usage` message.
#
#     Module is designed around variables' references (declare -n) introduced in bash 4.3. Public API contains a single function 
#     - `parseargs` (not `` quotes contrast to "" quotes refering to the whole module) - and a set of aliases that establish a helper 
#     interface for calling this function in various environments. In the simplest form `parseargs` takes two arguments - @p args 
#     containing name of the array holding arguments to be parsed and @p pargs (from 'positional arguments') containing name of the 
#     output array where the parsed positional arguments should be stored - and copies content of the array named @p args into the 
#     array named @p pargs. Although in this form it is not the most usefull tool, this is the simplest definition of what 'to parse
#     arguments' mean.
#
#     Arguments' description
#     ----------------------
#
#     To let user describe arguments of their functions and scripts in a more declarative - and so, in opitnion of the author, more 
#     readable - form "parseargs" (here the 'module' refers to the `parseargs` function and other functions co-designed to acomplish
#     aim of arguments' parsing) introduces a Unified Bash Arguments Description format (UBAD for short). If your are the a newbie in 
#     the bash world, don't bother nomenclature. UBAD is just a fancy common name for two things:
#
#          (1) definition of the data format (called 'UBAD table') describing an argument that in other languages would be called 
#              a 'dictionary' or a 'structure' with the strictly defined keys or fields
#          (2) set of rules describing meaning of it's fields in various contexts
#
#     In general the structure of the UBAD table (1) is following:
#
#           declare -A ubad_table=(
#                  [format]=STR
#                    [name]=STR
#                    [type]=STR
#                  [defaut]=STR_OR_INT
#                [variants]=LIST
#                   [range]=PAIR
#                    [help]=STR
#           )
#
#     Most of fields of the structure (or using bash nomenclature - this "hash table") are optional and although you can probably 
#     figure out their meaning, their properties are extensivey described below. UBAD descriptors are gathered into arrays
#     (UBAD lists) collecting definitions for arguments of the given _type_ (see below)
#
#           # Definition of arguments' descriptors
#           declare -A arga_description=(...)
#           declare -A argb_description=(...)
#           declare -A argc_description=(...)
#
#           # Compiled description of all arguments of the given type
#           declare -a pargs_descriptions=( arga_description argb_description argc_description )
#
#     Types of arguments
#     ------------------
#
#     Before one can talk about it, they need to descibe context of the talk (2). UBAD divides arguments into three categories:
#
#           1) positional arguments (pargs) - these are the most straighforward form of arguments. We are using them all the time
#              when calling various standard Linux tools. For example in `echo "Hello world"` the "Hello world" string is a positional
#              argument. Positional arguments are indexed with integer numbers starting from 1 (in bash, the 0 index is usually 
#              reserved for name of the program; as this is not what programmers like the most, "parseargs" tends to aim this issue 
#              too). In many scenarios positional arguments are also 'obligatory' arguments, but it is not always the case. Sometimes
#              (okay, maybe more 'times' than 'some') functions and scripts can take undefined number of arguments. We refer to this
#              as a 'variadic argument list'. In such cases meaning of these positional arguments is common (to some extend) and so 
#              are potential resitrictions that the function/script puts on them. Conceptually 'positional arguments' refer to two 
#              types of arguments:
#
#                      I ) required arguments
#                     II ) unnamed optional arguments
# 
#              Although it seems to narrow the full meaning of this term, author's expirience shows that it is usually 'enough'
#              to reason about this type of arguments. These arguments are passed to the function/script explicitly (what in context
#              of scripts means that they are passed on the command line) and they cannot begin with a hyphenh. Formally UBAD divides
#              positional arguments into three sets:
#
#                      I ) positional arguments (pargs) - all positional arguments
#                     II ) named positional arguments (nargs) - positional arguments that have names defined by the module's client;
#                          they always precede unnamed positional arguments
#                    III ) unnamed positional arguments (uargs) - positional arguments that hasve NOT names defined by the module's
#                          client
#
#              Both 'nargs' and 'uargs' are subsequences of 'pargs' where 'nargs' - if defined - always share the first argument
#              with 'pargs' and 'uargs' - if defined - shares the last argument with 'pargs'. 'nargs' and 'uargs' summs up (in the
#              sens of sets' summation) into the 'pargs'
#
#           2) optional arguments (opts) - these are optional arguments par excellence, i.e. thay may or may not be passed to the
#              function/script depending on the user's requirements. Optional arguments are also passed explicitly to the 
#              function/script and in contrast to positional arguments always begin with a hyphenh. "parseargs" uses standard GNU
#              'getopt' convention for defining optional arguments (in fact it uses `getopt` underthehood)
#
#           3) environmental arguments (envs) - as we all know bash has very poor namespacing capabilities. This mean that variables
#              from the caller's context are visible in the context of the called function unless they are explicitly hidden by the
#              definition with the matching name in the function's body. It is often pain in the neck for programmers working
#              with more robust languages that bash scripting language. However there are situatuions where such a feature may be
#              taken as an advantage. An example is a "logging" module from the BashUtils project. It's `log` function produces
#              an additional context information (which is in fact just a string describing from what part of the system the log
#              comes from) when the LOG_CONTEXT variable is defined. As the `log` function cannot tell the difference whether the 
#              variable has been declared globally or locally in the upper context this mechanism provides an easy way to unify
#              log context for the whole (or event part of!) call stack. Thanks to it one can avoid tedious implementation and 
#              copypasting of something like --log-context option in every function that can (directly or indirectly) produce some 
#              logs. As such a short cut can be handy from time to time, the "parseargs" module defines variables _implicitly_
#              passed to the function/script as the third type of arguments. Be carefull though, 'environmental arguments' are NOT
#              the same as the Linux environmental variables!
#
#     `parseopts` function uses three types of UBAD lists - 'args-definitions', 'opts-definitions' and 'envs-definitions' - to acquire
#     arguments' descriptions. Order of the UBAD tables in the 'args-definitions' lists determines order of described positional 
#     arguments. Results of the parsing routine are written into three hash arrays and two array:
#
#            1) pargs - array of all parsed positional arguments
#            2) nargs - hash array of parsed named positional arguments
#            2) uargs - array of parsed unnamed positional arguments
#            2) opts  - hash array of parsed optional arguments
#            2) envs  - hash array of parsed environmental arguments
#
#     UBAD Table
#     ----------
#
#     Having described types of argument distinguidhed by the module we can move to the description of the structure of the UBAD 
#     table. Underlying section tends to descibe subsequent fields in a way that is exhaustive for the topic and hopefully not for
#     the user :) It is devided into three subsections that descibe the table in context of every type of arguments apart.
#
#     [format] (optional/required)
#
#         This field wears two hats. First of all, it describes WHAT should be parsed. Meaning of 'what should be parsed' differs
#         from argument's type to type. and so requirements for this format are divided into threee categories.
#
#           --> Positional arguments (optional)
#
#                  For positional arguments this field - if given - takes one of three forms: 'NAME', 'NAME[n]' or 'NAME...',
#                  where 'NAME' is any (preferably human-readable) string consisting of alphanumerical characters and unerscored
#                  (may be an empty string). The first forms describes, that the UBAD table refers to a single positional argument. 
#                  The second form describes n subsequent positional arguments. The last form refers to a variadic list of arguments
#                  (note: UBAD table using 'NAME...' format - if used - should be the last element of the UBAD list descibing 
#                  positional argument. Further entries will be ommitted by the `parseargs` function)
#  
#                  If this field is not given, a single positional argument is assumed.
#
#           --> Optional arguments (required)
#
#                  For positional arguments this field hold a string representing a '|'-separated list of standard GNU options'
#                  identifiers. For more informations refer to `getopt`
#
#           --> Environmental arguments (required)
# 
#                  For environmental arguments this field contains name of the variable to be parsed
#
#         The secod function of the [format] field is providing a human-readable name of the argument for auto-generated `usage`
#         message. For positional arguments for which this field is optional, if no field given or when NAME is an empty string
#         the default name 'ARGx' is used, where 'x' is an index of the UBAD table in the UBAD list of positional argument
#         (indexed from 1)
# 
#     [name] (optional/required)
#
#         Name of the key under which the argument should be parsed into the destination hash array (nargs/opts/envs)
#
#           --> Positional arguments (optional)
# 
#                 For positional arguments, if this field is not defined, the parsed argument will be written into
#                 the 'uargs' array and not into the 'nargs' hash array. If defined, will correspond to the key in the
#                 'nargs' hash array which the parsed option will be stored under.
#
#                 If [name] field is given, and the [format] field describes multiple arguments ('NAME[n]' or 'NAME...' format)
#                 names of keys in the 'nargs' hash array will be produces by appending index of the argument (inside the group)
#                 to the value of the [name] field
# 
#           --> Optional arguments & Environmental arguments (required)
#
#                 For optionals and environmental arguments this field is required and defines name of the key in the 
#                 'opts' and 'envs' hash tables respectively that the parsed argument will be stored into.
# 
#     [type] (optional)
#
#         Type of the argument. This may be one of:
#
#              s|string) argument holds a string
#             i|integer) argument holds an integer
#                p|path) argument holds a path
#                f|flag) argument holds a flag (not applicable for positional arguments)
#
#          The default type is 'string'. Type of the argument may be used for automatic verification (only for integers and paths).
# 
#     [defaut] (optional, meaningless for flag arguments)
#
#          The default value of the argument if not parsed. 
#
#     [variants] (optional, meaningless for flag arguments)
#
#        '|'-separated list of valid values that the argument may take. By default every element of the list if trimmed (edge 
#        whitespace characters are removed) to enable user declare variants like this - 'var1 | var2 | var3' - instead of like this
#        'var1|var2|var3'. This behaviour may be changed by setting corresponding switch of the `parseargs` function
#
#        Variants may contain regex expressions (supported by the =~ operator) taken into '[...]'. '[]' characters can be scaped with 
#        a leading backslash (note: this is a goal, but it is not implemented yet)
# 
#     [range] (optional, meaningless for flag arguments)
#
#        Colon-separated pair of values defining 'MIN:MAX' range for the argument. For string-typed and path-typed arguments the
#        lexagographical comparison is used. This field is overwritten by the [variants] field, if given
#
#     [help] (optional)
#
#        Human-readable description of the argument used for automatic egneration of the 'usage' message
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

