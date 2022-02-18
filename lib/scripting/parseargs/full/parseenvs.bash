#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseenvs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Friday, 18th February 2022 5:35:23 pm
# @project  bash-utils
# @brief
#    
#    Environmental-arguments-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# A string reporting a library bug
declare __parseenvs_bug_msg_=$(echo \
        "A @fun parseenvs failed to parse it's own options. This is a library bug. Please" \
        "report it to the librarie's author."
)

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
#    @c 1 on bug
#    @c 2 on parsing error
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
#  -f,       --flag-default-defined  by default, flag arguments are unset when not 
#                                    parsed and set to 0 when parsed (in bash '0' means 
#                                    true and '1' means false). If this flag is set, 
#                                    the non-parsed flag-typed arguments will be set
#                                    to 1
#  -c,   --without-int-verification  if set, no integer-typed arguments validation is
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
    local -A      __flag_default_defined_parseenvs_opt_def_=( [format]="-f|--flag-default-defined"      [name]="flag_default_defined"      [type]="f" )
    local -A  __without_int_verification_parseenvs_opt_def_=( [format]="-c|--without-int-verification"  [name]="without_int_verification"  [type]="f" )
    local -A                __ubad_check_parseenvs_opt_def_=( [format]="-k|--ubad-check"                [name]="ubad_check"                [type]="f" )
    
    # UBAD list for options
    local -a __parseenvs_opts_definitions_=(
        __verbose_parseenvs_opt_def_
        __raw_parseenvs_opt_def_
        __flag_default_defined_parseenvs_opt_def_
        __without_int_verification_parseenvs_opt_def_
        __ubad_check_parseenvs_opt_def_
    )

    # -------------------------- Parse own options ----------------------------

    # Create hash array holding own options parsed
    local -a __parseenvs_own_args_=( "$@" )
    # Create hash array holding own options parsed
    local -A __parseenvs_own_opts_
    # Create hash array holding own options parsed
    local -a __parseenvs_own_pargs_

    # Parse own options
    parseopts                         \
        __parseenvs_own_args_         \
        __parseenvs_opts_definitions_ \
        __parseenvs_own_opts_         \
        __parseenvs_own_pargs_ ||
    {
        log_error "$__parseenvs_bug_msg_ ($code_)"
        return 1
    }

    # Get positional arguments
    local __parseenvs_envs_definitions_="${__parseenvs_own_pargs_[0]:-}"
    local __parseenvs_envs_="${__parseenvs_own_pargs_[1]:-}"

    # ---------------------------- Configure logs -----------------------------
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set __parseenvs_own_opts_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs
        
    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    ! is_var_set __parseenvs_own_opts_[ubad_check]       || 
    is_ubad_list "$__parseenvs_opts_definitions_" 'envs' || {
        log_error "Invalid envs UBAD table has been given"
        restore_log_config_from_default_stack
        return 4
    }
    
    # Check if arguments of a valid type has been given
    is_hash_array "$__parseenvs_envs_"  || {
        log_error "Argument of 'parseenvs' invalid type has been given"
        restore_log_config_from_default_stack
        return 3
    }

    # ------------------------- Parse own arguments ---------------------------

    local    __parseenvs_envs_definitions_="${__parseenvs_envs_definitions_}"
    local -n __parseenvs_envs_="${__parseenvs_envs_}"

    # ------------------------- Check helper options --------------------------

    # Check if 'default flag defined' option is passed
    local __parseenvs_flag_def_type_=$( is_var_set __parseopts_own_opts_[flag_default_defined] \
        && echo "defined" || echo "undefined" )
    # Check if 'raw' option is passed
    local __parseenvs_raw_=$( is_var_set __parseopts_own_opts_[raw] \
        && echo "raw" || echo "default" ) 

    # ======================================================================= #
    # ------------------------------ Parse envs ----------------------------- # 
    # ======================================================================= #
    
    # Hash array holding list of types corresponding to envs' types
    local -A __parseenvs_envs_types_

    # Parse options of the caller
    parseenvs_parse_envs                \
        __parseenvs_envs_definitions_   \
        "${__parseenvs_flag_def_type_}" \
        __parseenvs_envs_types_         \
        __parseenvs_envs_               ||
    {
        local ret_=$?
        restore_log_config_from_default_stack
        return $ret_
    }

    # ======================================================================= #
    # ----------------------------- Apply defaults -------------------------- #
    # ======================================================================= #

    # Apply default values
    apply_defaults                       \
        ${__parseenvs_envs_definitions_} \
        __parseenvs_envs_

    # ======================================================================= #
    # ----------------------------- Verify integers ------------------------- #
    # ======================================================================= #

    # If option requested
    if ! is_var_set __parseenvs_own_opts_[without_int_verification]; then

        # Verify integer-typed arguments
        verify_parsed_integers      \
            __parseenvs_envs_       \
            __parseenvs_envs_types_ ||
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
    verify_variants_and_ranges             \
        "${__parseenvs_envs_definitions_}" \
        __parseenvs_envs_types_            \
        "get_env_format"                   \
        "$__parseenvs_raw_"                \
        __parseenvs_envs_                  ||
    {
        local ret_=$?
        restore_log_config_from_default_stack
        return $ret_
    }

    # =========================================================================

    restore_log_config_from_default_stack
    return 0
}
