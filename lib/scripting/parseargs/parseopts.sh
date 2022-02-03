#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Sunday, 14th November 2021 9:24:22 pm
# @project  bash-utils
# @brief
#    
#    Options-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ========================================================== Configruation ========================================================= #

# Prefix of names defined in the file
declare old_prefix=${prefix:-}


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
#  -t,  --without-path-verification  if set, no path-typed arguments validation is
#                                    performed
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# ---------------------------------------------------------------------------------------
function parseopts() {
    
    # Arguments
    local __parseopts_args_="$1"
    local __parseopts_opts_definitions_="$2"
    local __parseopts_opts_="$3"
    local __parseopts_pargs_="$4"

    # ---------------------------- Define options -----------------------------

    # Options' definitions
    local -A                   __verbose_parseopts_own_opt_def_=( [format]="-v|--verbose"                   [name]="verbose"                   [type]="f" )
    local -A                       __raw_parseopts_own_opt_def_=( [format]="-r|--raw"                       [name]="raw"                       [type]="f" )
    local -A    __flag_default_undefined_parseopts_own_opt_def_=( [format]="-f|--flag-default-undefined"    [name]="flag_default_undefined"    [type]="f" )
    local -A  __without_int_verification_parseopts_own_opt_def_=( [format]="-c|--without-int-verification"  [name]="without_int_verification"  [type]="f" )
    local -A __without_path_verification_parseopts_own_opt_def_=( [format]="-t|--without-path-verification" [name]="without_path_verification" [type]="f" )

    # UBAD list for options
    local -a __parseopts_own_opts_definitions_=(
        __verbose_parseopts_own_opt_def_
        __raw_parseopts_own_opt_def_
        __flag_default_undefined_parseopts_own_opt_def_
        __without_int_verification_parseopts_own_opt_def_
        __without_path_verification_parseopts_own_opt_def_
    )

    # -------------------------- Parse own options ----------------------------

    # Helper variable used to store status code of commands
    local ret_

    # A string reporting a library bug
    local __parseopts_bug_msg_=$(echo \
         "A @fun parseopts failed to parse it's own options. This is a library bug. Please" \
         "report it to the user's author."
    )
    # Context string for bug messages of the 
    local __parseopts_bug_context_="parseopts"

    # List of own arguments
    local -a __parseopts_own_args_=( "$@" )
    # A hash array assosiating own options' formats with their names
    local -A __parseopts_own_options_names_
    # A hash array assosiating own options' formats with their types
    local -A __parseopts_own_options_types_

    # Parse own options' definitions
    parse_ubad_options_list               \
        __parseopts_own_opts_definitions_ \
        __parseopts_own_options_names_    \
        __parseopts_own_options_types_   || 
    {
        local LOG_CONTEXT="$__parseopts_bug_context_"
        log_error "$__parseopts_bug_msg_"
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
        __parseopts_own_getopt_longs_
    {
        local LOG_CONTEXT="$__parseopts_bug_context_"
        log_error "$__parseopts_bug_msg_"
        return 1
    }

    # Output of the `geopt` command
    local __parseopts_own_getopt_output_

    # Parse own options with getopt
    __parseopts_own_getopt_output_=$(
        wrap_getopt \
            __parseopts_own_args_
            __parseopts_own_getopt_shorts_
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


    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_ubad_options_list "$__parseopts_opts_definitions_" || return 3
    # Check if arguments of a valid type has been given
    is_array "$__parseopts_args_"      || return 1
    is_hash_array "$__parseopts_opts_" || return 1
    is_array "$__parseopts_pargs_"     || return 1

    # ------------------------- Parse own arguments ---------------------------

    local -n __parseopts_args_="$1"
    local -n __parseopts_opts_definitions_="$2"
    local -n __parseopts_opts_="$3"
    local -n __parseopts_pargs_="$4"
    
}
