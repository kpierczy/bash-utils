#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parsepargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Tuesday, 22nd February 2022 2:46:44 am
# @project  bash-utils
# @brief
#    
#    Positional-arguments-parsing routines of the "parsepargs" module
#    
# @see parsepargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# A string reporting a library bug
declare __parsepargs_bug_msg_=$(echo \
        "A @fun parsepargs failed to parse it's own options. This is a library bug. Please" \
        "report it to the librarie's author."
)

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses list of positional arguments named @p pargs based on the 
#    @p args_definitions UBAD list. Writes parsed arguments to the hash array named 
#    @p nargs if an argument is named or to the array named @P uargs if not.
#
# @param args
#    name of the array holding positional arguments to be parsed
# @param pargs_definitions
#    name of the UBAD list array holding arguments' definitions
# @param pargs (out)
#    name of the hash array where the parsed arguments will be written into
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 on library bug
#    @retval @c 2 on parsing error
#    @retval @c 3 if argument(s) of the wrong type has been given
#    @retval @c 4 if invalid UBAD list has been given
#
# @options (core)
#
#  -g INT,            --arg-num=INT  required number of positional arguments
#  -m INT,        --arg-num-min=INT  minimal number  of positional arguments 
#                                    (overwritten by --arg-num)
#  -x INT,        --arg-num-max=INT  maximal number  of positional arguments 
#                                    (overwritten by --arg-num)
#  
# @options (script-oriented)
# 
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails
#
# @options (minor)
# 
#  -f,       --flag-default-defined  by default, flag arguments are unset when not 
#                                    parsed and set to 0 when parsed (in bash '0' means 
#                                    true and '1' means false). If this flag is set, 
#                                    the non-parsed flag-typed arguments will be set
#                                    to 1
#  -r,                        --raw  by default, elements of the [variants] and 
#                                    [range] lists of the UBAD table are trimmed
#                                    after being parsed (edge whitespace characters 
#                                    are removed). If this flag is setl this behaviour
#                                    is suspended
#  -c,   --without-int-verification  if set, no integer-typed arguments validation is
#                                    performed
#  -k,                 --ubad-check  if set, the @p pargs_definitions definition will be
#                                    verified to be a valid UBAD list describing the
#                                    list of arguments; this procedure is computationally
#                                    expensnsive and so it optional
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# ---------------------------------------------------------------------------------------
function parsepargs() {
    
    # Arguments
    local __parsepargs_args_
    local __parsepargs_pargs_definitions_
    local __parsepargs_pargs_

    # Options' definitions
    local -A                   __arg_num_parsepargs_opt_def_=( [format]="-g|--arg-num"                   [name]="arg_num"                   [type]="i" )
    local -A               __arg_num_min_parsepargs_opt_def_=( [format]="-m|--arg-num-min"               [name]="arg_num_min"               [type]="i" )
    local -A               __arg_num_max_parsepargs_opt_def_=( [format]="-x|--arg-num-max"               [name]="arg_num_max"               [type]="i" )
    local -A                   __verbose_parsepargs_opt_def_=( [format]="-v|--verbose"                   [name]="verbose"                   [type]="f" )
    local -A      __flag_default_defined_parsepargs_opt_def_=( [format]="-f|--flag-default-defined"      [name]="flag_default_defined"      [type]="f" )
    local -A                       __raw_parsepargs_opt_def_=( [format]="-r|--raw"                       [name]="raw"                       [type]="f" )
    local -A  __without_int_verification_parsepargs_opt_def_=( [format]="-c|--without-int-verification"  [name]="without_int_verification"  [type]="f" )
    local -A                __ubad_check_parsepargs_opt_def_=( [format]="-k|--ubad-check"                [name]="ubad_check"                [type]="f" )

    # UBAD list for options
    local -a __parsepargs_opts_definitions_=(
        __arg_num_parsepargs_opt_def_
        __arg_num_min_parsepargs_opt_def_
        __arg_num_max_parsepargs_opt_def_
        __verbose_parsepargs_opt_def_
        __flag_default_defined_parsepargs_opt_def_
        __raw_parsepargs_opt_def_
        __without_int_verification_parsepargs_opt_def_
        __ubad_check_parsepargs_opt_def_
    )

    # -------------------------- Parse own options ----------------------------

    # Create hash array holding own options parsed
    local -a __parsepargs_own_args_=( "$@" )
    # Create hash array holding own options parsed
    local -A __parsepargs_own_opts_
    # Create hash array holding own options parsed
    local -a __parsepargs_own_pargs_
    
    # Parse own options
    parseopts                         \
        __parsepargs_own_args_         \
        __parsepargs_opts_definitions_ \
        __parsepargs_own_opts_         \
        __parsepargs_own_pargs_ ||
    {
        log_error "$__parsepargs_bug_msg_ ($code_)"
        return 1
    }

    # Get positional arguments
    local __parsepargs_args_="${__parsepargs_own_pargs_[0]:-}"
    local __parsepargs_pargs_definitions_="${__parsepargs_own_pargs_[1]:-}"
    local __parsepargs_pargs_="${__parsepargs_own_pargs_[2]:-}"
    
    # ---------------------------- Configure logs -----------------------------
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set __parsepargs_own_opts_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    ! is_var_set __parsepargs_own_opts_[ubad_check]       || 
    is_ubad_list "$__parsepargs_pargs_definitions_" 'pargs' || {
        log_error "Invalid pargs UBAD table has been given"
        restore_log_config_from_default_stack
        return 4
    }

    # Check if arguments of a valid type has been given
    is_array "$__parsepargs_args_"  || {
        log_error "Argument of 'parsepargs' (args) has no valid type (array)"
        restore_log_config_from_default_stack
        return 3
    }
    is_hash_array "$__parsepargs_pargs_"  || {
        log_error "Argument of 'parsepargs' (pargs) has no valid type (hash array)"
        restore_log_config_from_default_stack
        return 3
    }

    # ------------------------- Parse own arguments ---------------------------

    local __parsepargs_args_="$__parsepargs_args_"
    local __parsepargs_pargs_definitions_="$__parsepargs_pargs_definitions_"
    local __parsepargs_pargs_="$__parsepargs_pargs_"

    # ------------------------- Check helper options --------------------------

    # Check if 'default flag defined' option is passed
    local __parsepargs_flag_def_type_=$( is_var_set __parsepargs_own_opts_[flag_default_defined] \
        && echo "defined" || echo "undefined" )
    # Check if 'raw' option is passed
    local __parsepargs_raw_=$( is_var_set __parsepargs_own_opts_[raw] \
        && echo "raw" || echo "default" ) 

    # ======================================================================= #
    # ---------------- Verify number of positional arguments ---------------- # 
    # ======================================================================= #

    # Get reference to the arguments' list
    local -n __parsepargs_args_ref_="$__parsepargs_args_"

    # Get number of positional arguments
    local pos_args_num="${#__parsepargs_args_ref_[@]}"

    # If required number of positional arguments given
    if is_var_set __parsepargs_own_opts_[arg_num]; then

        # Check if actual number of arguments matched
        if (("$pos_args_num" != "${__parsepargs_own_opts_[arg_num]}")); then
            log_error "($pos_args_num) positional arguments has been given when (${__parsepargs_own_opts_[arg_num]}) is required"
            restore_log_config_from_default_stack
            return 2
        fi

    # Else
    else

        # If maximal number of positional arguments given
        if is_var_set __parsepargs_own_opts_[arg_num_min]; then

            # Check if actual number of arguments is NOT lesser than minimal
            if (("$pos_args_num" < "${__parsepargs_own_opts_[arg_num_min]}")); then
                log_error "($pos_args_num) positional arguments has been given when at least (${__parsepargs_own_opts_[arg_num_min]}) is required"
                restore_log_config_from_default_stack
                return 2
            fi
            
        fi

        # If minimal number of positional arguments given
        if is_var_set __parsepargs_own_opts_[arg_num_max]; then

            # Check if actual number of arguments is NOT greater than minimal
            if (("$pos_args_num" > "${__parsepargs_own_opts_[arg_num_max]}")); then
                log_error "($pos_args_num) positional arguments has been given when at most (${__parsepargs_own_opts_[arg_num_max]}) is required"
                restore_log_config_from_default_stack
                return 2
            fi
            
        fi
        
    fi

    # ======================================================================= #
    # ----------------------------- Parse pargs ----------------------------- # 
    # ======================================================================= #

    # Hash array holding list of types corresponding to pargs' types
    local -A __parsepargs_pargs_types_

    # Parse options of the caller
    parsepargs_parse_pargs                 \
        "$__parsepargs_args_"              \
        "$__parsepargs_pargs_definitions_" \
        "$__parsepargs_flag_def_type_"     \
        __parsepargs_pargs_types_          \
        "$__parsepargs_pargs_"             ||
    {
        local ret_=$?
        restore_log_config_from_default_stack
        return $ret_
    }

    # ======================================================================= #
    # ----------------------------- Verify integers ------------------------- #
    # ======================================================================= #
    
    # If option requested
    if ! is_var_set __parsepargs_own_opts_[without_int_verification]; then

        # Verify integer-typed arguments
        verify_parsed_integers        \
            "$__parsepargs_pargs_"    \
            __parsepargs_pargs_types_ ||
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
    verify_variants_and_ranges               \
        "${__parsepargs_pargs_definitions_}" \
        __parsepargs_pargs_types_            \
        "get_parg_format"                    \
        "$__parsepargs_raw_"                 \
        __parsepargs_pargs_                  ||
    {
        local ret_=$?
        restore_log_config_from_default_stack
        return $ret_
    }

    # =========================================================================

    restore_log_config_from_default_stack
    return 0
}

# ======================================================== Helper functions ======================================================== #


# ---------------------------------------------------------------------------------------
# @brief Counts number of variadic arguments parsed by @fun parsepargs to the `pargs`
#    hash array
#
# @param defs
#    name  of the UBAD list describing positional arguments
# @param pargs
#    name of the `pargs` hash array
#
# @returns
#    @retval @c 0 on success
#    @retval @c 1 if @p defs does nto describe variadic arguments pack
#
# @outputs
#    number of variadic arguments or nothing on error; if variadic arguments define 
#    [default] value, the @c 'def' will be written to the output
# ---------------------------------------------------------------------------------------
function get_variadic_args_num() {

    # Parse arguments
    local __get_variadic_args_num_defs_="$1"
    local __get_variadic_args_num_pargs_="$2"
    
    # Get reference to the UBAD list
    local -n __get_variadic_args_num_defs_ref_="$__get_variadic_args_num_defs_"
    # Prepare storage for the name of variadic arguments
    local __get_variadic_args_num_variadic_name_=""

    local __get_variadic_args_num_defs_def_

    # Iterate over UBAD list to find whether variadic argument are defined
    for __get_variadic_args_num_defs_def_ in "${__get_variadic_args_num_defs_ref_[@]}"; do

        # Get reference to the UBAD table
        local -n __get_variadic_args_num_defs_def_ref_="$__get_variadic_args_num_defs_def_"
        # If table describes variadic argument, get it's name
        if is_var_set __get_variadic_args_num_defs_def_ref_[format]; then
            if ends_with "${__get_variadic_args_num_defs_def_ref_[format]}" '...'; then
                __get_variadic_args_num_variadic_name_="${__get_variadic_args_num_defs_def_ref_[name]}"
            fi
        fi

    done

    # If definition was not found, return error
    is_var_set_non_empty __get_variadic_args_num_variadic_name_ || return 1

    # Initialize counter of variadic arguments
    local __get_variadic_args_num_count_='0'
    # Get reference to the parsed arguments
    local -n __get_variadic_args_num_pargs_ref_="$__get_variadic_args_num_pargs_"

    local __get_variadic_args_num_pargs_name_

    # Iterate over names of parsed arguments
    for __get_variadic_args_num_pargs_name_ in "${!__get_variadic_args_num_pargs_ref_[@]}"; do

        # If name matches variadic's name, set counter to @c 0 and break loop (as it means that the default valeu was used for the variadic pack)
        if [[ "$__get_variadic_args_num_pargs_name_" == "$__get_variadic_args_num_variadic_name_" ]]; then
            __get_variadic_args_num_count_='def'
            break
        # Else, if name starts with the name of the variadic (but is followed by digits), increment counter
        elif [[ "$__get_variadic_args_num_pargs_name_" =~ ${__get_variadic_args_num_variadic_name_}[[:digit:]]* ]]; then
            ((__get_variadic_args_num_count_ = $__get_variadic_args_num_count_ + 1))
        fi
        
    done

    # Print counted number
    echo "$__get_variadic_args_num_count_"

    return 0
}
