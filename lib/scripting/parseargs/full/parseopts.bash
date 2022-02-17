#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Thursday, 17th February 2022 8:20:55 pm
# @project  bash-utils
# @brief
#    
#    Options-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Context string for log messages of the submodule
declare __parseopts_log_context_="parseopts"

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
#  -h,                  --with-help  if set, the UBAD table for the help option (with 
#                                    standard -h|--help format) will be appended to the
#                                    UBAD list 
#  -f,     --flag-default-undefined  by default, flag arguments are set to 1 when not 
#                                    parsed (in bash '0' means true and '1' means false)
#                                    and set to 0 when parsed. If this flag is set, 
#                                    the non-parsed flag-typed arguments will stay
#                                    undefined in 'opts' hash array 
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
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# @outputs
#    error logs in 'verbose' mode
# @outputs
#    If 'help' options has been parsed and 'verbose' mode has been requested, the
#    auto-generated description of options is generated
# ---------------------------------------------------------------------------------------
function parseopts() {

    # ---------------------------- Define options -----------------------------

    # Options' definitions
    local -A                      __help_parseopts_own_opt_def_=( [format]="-h|--with-help"                [name]="help"                      [type]="f" )
    local -A    __flag_default_undefined_parseopts_own_opt_def_=( [format]="-f|--flag-default-undefined"   [name]="flag_default_undefined"    [type]="f" )
    local -A                   __verbose_parseopts_own_opt_def_=( [format]="-v|--verbose"                  [name]="verbose"                   [type]="f" )
    local -A  __without_int_verification_parseopts_own_opt_def_=( [format]="-c|--without-int-verification" [name]="without_int_verification"  [type]="f" )
    local -A                       __raw_parseopts_own_opt_def_=( [format]="-r|--raw"                      [name]="raw"                       [type]="f" )

    # UBAD list for options
    local -a __parseopts_own_opts_definitions_=(
        __help_parseopts_own_opt_def_
        __flag_default_undefined_parseopts_own_opt_def_
        __verbose_parseopts_own_opt_def_
        __without_int_verification_parseopts_own_opt_def_
        __raw_parseopts_own_opt_def_
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

    # ---------------------------- Configure logs -----------------------------
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set __parseopts_own_options_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs
        
    # ------------------------- Validate arguments ----------------------------

    # Check if a valid UBAD list has been given (@define)
    is_ubad_list "$__parseopts_opts_definitions_" 'opts' || {
        log_error "Invalid UBDAT table has been given"
        restore_log_config_from_default_stack
        return 4
    }
    
    # Check if arguments of a valid type has been given
    is_array      "$__parseopts_args_"  &&
    is_hash_array "$__parseopts_opts_"  &&
    is_array      "$__parseopts_pargs_" || {
        log_error "Argument of invalid type has been given"
        restore_log_config_from_default_stack
        return 3
    }

    # ------------------------- Parse own arguments ---------------------------

    local    __parseopts_args_="${__parseopts_args_}"
    local -n __parseopts_opts_definitions_="${__parseopts_opts_definitions_}"
    local -n __parseopts_opts_="${__parseopts_opts_}"
    local -n __parseopts_pargs_="${__parseopts_pargs_}"

    # ------------------------- Check helper options --------------------------

    # Check if 'default flag undefined' option is passed
    local __parseopts_flag_def_type_="defined"
    if is_var_set __parseopts_own_options_[flag_default_undefined]; then
        __parseopts_flag_def_type_="undefined"
    fi

    # Check if 'raw' option is passed
    local __parseopts_raw_="default"
    if is_var_set __parseopts_own_options_[raw]; then
        __parseopts_raw_="raw"
    fi

    # ---------------------------- Copy UBAD list -----------------------------

    # Make local copy of the UBAD list than may be modified in the body of the function
    local -a __parseopts_opts_definitions_copy_=( "${__parseopts_opts_definitions_[@]}" )

    # ======================================================================= #
    # ----------------------------- Parse options --------------------------- # 
    # ======================================================================= #

    # ------------------------ Add 'help' UBDAT table -------------------------
    
    local -A __help_parseopts_opt_def_=( [format]="-h|--help" [name]="help" [type]="f" [help]="Shows this usage text")

    # If option enabled, append table
    if is_var_set __parseopts_own_options_[help]; then

        # Append table to the list
        __parseopts_opts_definitions_copy_+=(__help_parseopts_opt_def_)

    fi
    
    # ---------------------------- Parse options ------------------------------

    # Array holding list of names of valid options
    local -a __parseopts_opts_names_
    # Hash array holding list of types corresponding to options' names
    local -A __parseopts_opts_types_

    # Parse options of the caller
    parseopts_parse_options                \
        __parseopts_opts_definitions_copy_ \
        ${__parseopts_args_}               \
        ${__parseopts_flag_def_type_}      \
        __parseopts_opts_names_            \
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
        generate_options_description __parseopts_opts_definitions_copy_
        restore_log_config_from_default_stack
        return 5    
    }

    # ======================================================================= #
    # ----------------------------- Apply defaults -------------------------- #
    # ======================================================================= #

    # Hash array holding list of default values corresponding to non-flag options' names
    local -A __parseopts_opts_defaults_
    # Parse default values
    parseopts_parse_field                  \
        __parseopts_opts_definitions_copy_ \
        'default'                          \
        __parseopts_opts_defaults_         ||
    {
        local ret_=$?
        log_error "Failed to parse default values from the UBAD list"
        restore_log_config_from_default_stack
        return $ret_
    }

    local defaulted_option

    # Iterate through provided defaults
    for defaulted_option in "${!__parseopts_opts_defaults_[@]}"; do
        # If option has not been parsed, write the default option
        if ! is_var_set __parseopts_opts_["$defaulted_option"]; then
            __parseopts_opts_["$defaulted_option"]=${__parseopts_opts_defaults_[$defaulted_option]}
        fi
    done

    # ======================================================================= #
    # ----------------------------- Verify integers ------------------------- #
    # ======================================================================= #

    # If option requested
    if ! is_var_set __parseopts_own_options_[without_int_verification]; then

        local name

        # Iterate through parsed options
        for name in "${!__parseopts_opts_[@]}"; do
            # Check if option is integer-typed
            if is_ubad_arg_integer "${__parseopts_opts_types_[$name]}"; then

                # Get the parse value
                local parsed_value="${__parseopts_opts_[$name]}"
                
                # Check if option's value represents integer
                if ! represents_integer "$parsed_value"; then
                    log_error "($parsed_value) passed to integer-typed option '$name'"
                    restore_log_config_from_default_stack
                    return 2
                fi
            fi
        done
        
    fi

    # ======================================================================= #
    # ------------------------- Verify variants/ranges ---------------------- #
    # ======================================================================= #

    # ------------------ Parse variants/ranges definitions --------------------

    # Hash array holding list of variants corresponding to non-flag options' names
    local -A __parseopts_opts_variants_
    # Parse variants values
    parseopts_parse_field                  \
        __parseopts_opts_definitions_copy_ \
        'variants'                         \
        __parseopts_opts_variants_        ||
    {
        local ret_=$?
        log_error "Failed to parse variants from the UBAD list"
        restore_log_config_from_default_stack
        return $ret_
    }    

    # Hash array holding list of ranges corresponding to non-flag options' names
    local -A __parseopts_opts_ranges_
    # Parse ranges values
    parseopts_parse_field                  \
        __parseopts_opts_definitions_copy_ \
        'range'                            \
        __parseopts_opts_ranges_         ||
    {
        local ret_=$?
        log_error "Failed to parse ranges from the UBAD list"
        restore_log_config_from_default_stack
        return $ret_
    }    

    # --------------- Verify if variants/ranges are respected -----------------
    
    # Iterate through parsed options
    for name in "${!__parseopts_opts_[@]}"; do
        # Skip flag options
        if ! is_ubad_arg_flag "${__parseopts_opts_types_[$name]}"; then

            # If variants are defined for the option
            if is_var_set __parseopts_opts_variants_["$name"]; then
                
                # Array holding valid variants of the option
                local -a variants=()
                # Parse variants
                parse_vatiants                             \
                    "${__parseopts_opts_variants_[$name]}" \
                    "${__parseopts_raw_}"                  \
                    variants
                
                # Check whether option's value meet valid variants
                is_array_element variants "${__parseopts_opts_[$name]}" ||
                {

                    local ret_=$?
                    log_error \
                        "Option '$(get_option_format ${__parseopts_args_} __parseopts_opts_definitions_copy_ $name)' " \
                        "parsed with value (${__parseopts_opts_[$name]}) when one of" "{ ${__parseopts_opts_variants_[$name]} }"\
                        " is required"
                    restore_log_config_from_default_stack
                    return $ret_
                }

            # Else, if range is defined for the option
            elif is_var_set __parseopts_opts_ranges_["$name"]; then

                # Limits of the valid range
                local min
                local max
                # Parse variants
                parse_range                              \
                    "${__parseopts_opts_ranges_[$name]}" \
                    "${__parseopts_raw_}"                \
                    min max

                local min_valid
                local max_valid

                # For integer-typed variables, use numerical comparisons
                if is_ubad_arg_integer "${__parseopts_opts_types_[$name]}"; then
                    (( "$min" > "${__parseopts_opts_[$name]}" )) && min_valid=1 || min_valid=0
                    (( "$max" < "${__parseopts_opts_[$name]}" )) && max_valid=1 || max_valid=0
                # For other-typed variables, use lexicalographical comparisons
                else
                    [[ "$min" > "${__parseopts_opts_[$name]}" ]] && min_valid=1 || min_valid=0
                    [[ "$max" < "${__parseopts_opts_[$name]}" ]] && max_valid=1 || max_valid=0
                fi

                # Check whether option's value meet valid variants
                if [[ "$min_valid" != "0" ]] || [[ "$max_valid" != "0" ]]; then

                    local ret_=$?
                    log_error \
                        "Option '$(get_option_format ${__parseopts_args_} __parseopts_opts_definitions_copy_ $name)'"\
                        " parsed with value (${__parseopts_opts_[$name]}) when it is limited to ( $min : $max ) range"
                    restore_log_config_from_default_stack
                    return $ret_

                fi
            fi
            
        fi
    done

    # =========================================================================

    restore_log_config_from_default_stack
    return 0
}
