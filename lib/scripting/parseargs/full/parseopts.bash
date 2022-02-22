#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Tuesday, 22nd February 2022 2:06:32 am
# @project  bash-utils
# @brief
#    
#    Options-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# A string reporting a library bug
declare __parseopts_bug_msg_=$(echo \
        "A @fun parseopts failed to parse it's own options. This is a library bug. Please" \
        "report it to the librarie's author."
)

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
#    @retval @c 0 on success
#    @retval @c 1 if function sufferred from the bug
#    @retval @c 2 if invalid option has been passed
#    @retval @c 3 if argument(s) of the wrong type has been given
#    @retval @c 4 if invalid UBAD list has been given
#    @retval @c 5 if '-h|--help' option has been parsed
#
# @options (script-oriented)
# 
# 
#  -h,                  --with-help  if set, the UBAD table for the help option (with 
#                                    standard -h|--help format) will be appended to the
#                                    UBAD list 
#  -f,       --flag-default-defined  by default, flag arguments are unset when not 
#                                    parsed and set to 0 when parsed (in bash '0' means 
#                                    true and '1' means false). If this flag is set, 
#                                    the non-parsed flag-typed arguments will be set
#                                    to 1
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails
#  -c,   --without-int-verification  if set, no integer-typed arguments validation is
#                                    performed (i.e. strings passed to integer-typed 
#                                    options are not verified to represent numbers)
#  -r,                        --raw  by default, elements of the [variants] and 
#                                    [range] lists of the UBAD table are trimmed
#                                    after being parsed (edge whitespace characters 
#                                    are removed). If this flag is setl this behaviour
#                                    is suspended
#  -k,                 --ubad-check  if set, the @p opts_definitions definition will be
#                                    verified to be a valid UBAD list describing the
#                                    list of arguments; this procedure is computationally
#                                    expensnsive and so it optional
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# @outputs
#    error logs in 'verbose' mode
# @outputs
#    If 'help' options has been parsed the function returns immediatelly without
#    verifying values of arguments
# ---------------------------------------------------------------------------------------
function parseopts() {

    # ---------------------------- Define options -----------------------------

    # Options' definitions
    local -A                      __help_parseopts_own_opt_def_=( [format]="-h|--with-help"                [name]="help"                      [type]="f" )
    local -A      __flag_default_defined_parseopts_own_opt_def_=( [format]="-f|--flag-default-defined"     [name]="flag_default_defined"      [type]="f" )
    local -A                   __verbose_parseopts_own_opt_def_=( [format]="-v|--verbose"                  [name]="verbose"                   [type]="f" )
    local -A  __without_int_verification_parseopts_own_opt_def_=( [format]="-c|--without-int-verification" [name]="without_int_verification"  [type]="f" )
    local -A                       __raw_parseopts_own_opt_def_=( [format]="-r|--raw"                      [name]="raw"                       [type]="f" )
    local -A                __ubad_check_parseopts_own_opt_def_=( [format]="-k|--ubad-check"               [name]="ubad_check"                [type]="f" )

    # UBAD list for options
    local -a __parseopts_own_opts_definitions_=(
        __help_parseopts_own_opt_def_
        __flag_default_defined_parseopts_own_opt_def_
        __verbose_parseopts_own_opt_def_
        __without_int_verification_parseopts_own_opt_def_
        __raw_parseopts_own_opt_def_
        __ubad_check_parseopts_own_opt_def_
    )

    # -------------------------- Parse own options ----------------------------

    # Create hash array holding own options parsed
    local -a __parseopts_own_args_=( "$@" )
    # Create hash array holding own options parsed
    local -A __parseopts_own_opts_
    # Create hash array holding own options parsed
    local -a __parseopts_own_pargs_

    # Parse own options
    parseopts_parseopts        \
        __parseopts_own_args_  \
        __parseopts_own_opts_  \
        __parseopts_own_pargs_ ||
    {
        return $?
    }
    
    # Get positional arguments
    local __parseopts_args_="${__parseopts_own_pargs_[0]:-}"
    local __parseopts_opts_definitions_="${__parseopts_own_pargs_[1]:-}"
    local __parseopts_opts_="${__parseopts_own_pargs_[2]:-}"
    local __parseopts_pargs_="${__parseopts_own_pargs_[3]:-}"

    # ---------------------------- Configure logs -----------------------------
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set __parseopts_own_opts_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs
        
    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    ! is_var_set __parseopts_own_opts_[ubad_check]       || 
    is_ubad_list "$__parseopts_opts_definitions_" 'opts' || {
        log_error "Invalid UBDAT table has been given"
        restore_log_config_from_default_stack
        return 4
    }
    
    # Check if arguments of a valid type has been given
    is_array "$__parseopts_args_"  || {
        log_error "Argument of 'parseopts' (args) has no a valid type (array)"
        restore_log_config_from_default_stack
        return 3
    }
    is_hash_array "$__parseopts_opts_"  || {
        log_error "Argument of 'parseopts' (opts) has no a valid type (hash array)"
        restore_log_config_from_default_stack
        return 3
    }
    is_array "$__parseopts_pargs_" || {
        log_error "Argument of 'parseopts' (pargs) has no a valid type (array)"
        restore_log_config_from_default_stack
        return 3
    }

    # ------------------------- Parse own arguments ---------------------------

    local    __parseopts_args_="${__parseopts_args_}"
    local -n __parseopts_opts_definitions_="${__parseopts_opts_definitions_}"
    local -n __parseopts_opts_="${__parseopts_opts_}"
    local -n __parseopts_pargs_="${__parseopts_pargs_}"

    # ------------------------- Check helper options --------------------------

    # Check if 'default flag defined' option is passed
    local __parseopts_flag_def_type_=$( is_var_set __parseopts_own_opts_[flag_default_defined] \
        && echo "defined" || echo "undefined" )
    # Check if 'raw' option is passed
    local __parseopts_raw_=$( is_var_set __parseopts_own_opts_[raw] \
        && echo "raw" || echo "default" ) 

    # ======================================================================= #
    # ----------------------------- Parse options --------------------------- # 
    # ======================================================================= #

    # Make local copy of the UBAD list that may be modified in the body of the function
    local -a __parseopts_opts_definitions_copy_=( ${__parseopts_opts_definitions_[@]} )

    # ------------------------ Add 'help' UBAD table --------------------------

    # If option enabled, append table
    if is_var_set __parseopts_own_opts_[help]; then

        # Append table to the list
        autogenerate_help_option __parseopts_opts_definitions_copy_

    fi
    
    # ---------------------------- Parse options ------------------------------

    # Hash array holding list of types corresponding to options' names
    local -A __parseopts_opts_types_
    
    # Parse options of the caller
    parseopts_parse_options                \
        __parseopts_opts_definitions_copy_ \
        ${__parseopts_args_}               \
        ${__parseopts_flag_def_type_}      \
        __parseopts_opts_types_            \
        __parseopts_opts_                  \
        __parseopts_pargs_                 ||
    {
        local ret_=$?
        restore_log_config_from_default_stack
        return $ret_
    }

    # If help requested, return (help is NOT requested when it's value is non-set or set to '1' while -f option given )
    ! is_var_set __parseopts_opts_[help] || [[ "${__parseopts_opts_[help]}" == "1" ]] || 
    {
        restore_log_config_from_default_stack
        return 5    
    }

    # ======================================================================= #
    # ----------------------------- Apply defaults -------------------------- #
    # ======================================================================= #

    # Apply default values
    apply_defaults                         \
        __parseopts_opts_definitions_copy_ \
        __parseopts_opts_

    # ======================================================================= #
    # ----------------------------- Verify integers ------------------------- #
    # ======================================================================= #

    # If option requested
    if ! is_var_set __parseopts_own_opts_[without_int_verification]; then

        # Verify integer-typed arguments
        verify_parsed_integers      \
            __parseopts_opts_       \
            __parseopts_opts_types_ ||
        {
            local ret_=$?
            restore_log_config_from_default_stack
            return $ret_
        }
        
    fi

    # ======================================================================= #
    # ------------------------- Verify variants/ranges ---------------------- #
    # ======================================================================= #

    # Verify variants/ranges
    verify_variants_and_ranges                   \
        __parseopts_opts_definitions_copy_       \
        __parseopts_opts_types_                  \
        "get_option_format ${__parseopts_args_}" \
        "$__parseopts_raw_"                      \
        __parseopts_opts_                        ||
    {
        local ret_=$?
        restore_log_config_from_default_stack
        return $ret_
    }

    # =========================================================================

    restore_log_config_from_default_stack
    return 0
}
