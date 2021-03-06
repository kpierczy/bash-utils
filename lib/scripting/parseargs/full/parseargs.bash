#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 2:37:47 pm
# @modified   Thursday, 12th May 2022 7:52:43 pm
# @project  bash-utils
# @brief
#    
#    Main file of the "parseargs" module
#
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Context string for log messages of the submodule
declare __parseargs_log_context_="parseargs"
# A string reporting a library bug
declare __parseargs_bug_msg_=$(echo \
        "A @fun parseargs failed to parse it's own options. This is a library bug. Please" \
        "report it to the librarie's author."
)

# ============================================================ Function ============================================================ #

# Parseargs return values
declare PARSEARGS_SUCCESS=0
declare PARSEARGS_BUG=1
declare PARSEARGS_INVALID_ARG=2
declare PARSEARGS_INVALID_TYPE=3
declare PARSEARGS_INVALID_UBAD_LIST=4
declare PARSEARGS_HELP_REQUESTED=5

# ---------------------------------------------------------------------------------------
# @brief Parses comand line arguments in an extensive way
#
# @param args 
#    name of the array holding list of arguments to be parsed
# @param parsed (out)
#    name of the array where the parsed positional arguments should be placed
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 if function sufferred from the bug
#    @retval @c 2 if invalid argument has been passed
#    @retval @c 3 if argument(s) of the wrong type has been given
#    @retval @c 4 if invalid UBAD list has been given
#    @retval @c 5 if '-h|--help' option has been parsed
#
# @description
#
#     For extended description of the `parseargs` function refer to the @description
#     of this file and to the given @examples
#
# @options (core)
#
#  -a HARR, --pargs-definitions=HARR  name of the 'args-definitions' UBAD list
#  -o HARR,  --opts-definitions=HARR  name of the 'opts-definitions' UBAD list
#  -e HARR,  --envs-definitions=HARR  name of the 'envs-definitions' UBAD list
# 
#  -g INT,             --arg-num=INT  required number of positional arguments
#  -m INT,         --arg-num-min=INT  minimal number  of positional arguments 
#                                     (overwritten by --arg-num)
#  -x INT,         --arg-num-max=INT  maximal number  of positional arguments 
#                                     (overwritten by --arg-num)
#   
#  -n HARR,             --pargs=HARR  name of the 'pargs' hash array
#  -p HARR,              --opts=HARR  name of the 'opts' hash array
#  -i HARR,              --envs=HARR  name of the 'envs' hash array
#  
# @options (script-oriented)
# 
#  -v,                      --verbose  if set, the verbose logs will be printed to the
#                                      stdout when the parsing process fails; also 
#                                      printing of the 'usage' message will be handled 
#                                      automatically if the '-h|--help' option will be
#                                      parsed and the usage string is defined
#  -h,                    --with-help  if set, the UBAD table for the help option (with 
#                                      standard -h|--help format) will be appended to the
#                                      UBAD list 
#  -w STR,           --with-usage=STR  usage string to be printed when the --verbose 
#                                      switch is set
#  -x,              --with-auto-usage  if set, the automatic usage message will be 
#                                      printed, when the --verbose switch is set 
#                                      (overwritten by --with-usage)
#  -d STR,     --with-description=STR  name of the variable containing description string 
#                                      to be printed in the usage string
#      --with-prepend-description=STR  name of the variable containing description string 
#                                      that should be prepended to the descriptions string
# --with-append-pargs-description=STR  name of the variable containing description string 
#                                      that should be appended to the descriptions string
#                                      after positional arguments' description
#  --with-append-opts-description=STR  name of the variable containing description string 
#                                      that should be appended to the descriptions string
#                                      after optional arguments' description
#  --with-append-envs-description=STR  name of the variable containing description string 
#                                      that should be appended to the descriptions string
#                                      after environmental arguments' description
#       --with-append-description=STR  name of the variable containing description string 
#                                      that should be appended to the descriptions string
#  -z STR,        --with-cmd-name=STR  name of the variable containing name of the command 
#                                      to be printed in the usage message (default: 
#                                      $(basename $0))
#
# @options (minor)
# 
#  -r,                         --raw  by default, elements of the [variants] and 
#                                     [range] lists of the UBAD table are trimmed
#                                     after being parsed (edge whitespace characters 
#                                     are removed). If this flag is setl this behaviour
#                                     is suspended
#  -f,        --flag-default-defined  by default, flag arguments are unset when not 
#                                     parsed and set to 0 when parsed (in bash '0' means 
#                                     true and '1' means false). If this flag is set, 
#                                     the non-parsed flag-typed arguments will be set
#                                     to 1
#  -c,    --without-int-verification  if set, no integer-typed arguments validation is
#                                     performed
#  -k,                  --ubad-check  if set, the @p opts_definitions definition will be
#                                     verified to be a valid UBAD list describing the
#                                     list of arguments; this procedure is computationally
#                                     expensnsive and so it optional
#
# @environment
#    
#                        LOG_CONTEXT  context for the logs printed by the function in the
#                                     --verbose mode
#       ARGUMENTS_DESCRIPTION_INTEND  width of the intendation for argument's 
#                                     description provided by the auto-generated help 
#                                     message
#   ARGUMENTS_DESCRIPTION_LENGTH_MAX  maximal width of the auto-generated help message
#
# ---------------------------------------------------------------------------------------
function parseargs() {
    
    local LOG_CONTEXT="$__parseargs_log_context_"

    # ---------------------------- Define options -----------------------------
    
    # Arguments
    local __parseargs_args_
    local __parseargs_parsed_

    # Options' definitions
    local -A              __args_definitions_parseargs_opt_def_=( [format]="-a|--pargs-definitions"          [name]="pargs_definitions"             [type]="s" )
    local -A              __opts_definitions_parseargs_opt_def_=( [format]="-o|--opts-definitions"           [name]="opts_definitions"              [type]="s" )
    local -A              __envs_definitions_parseargs_opt_def_=( [format]="-e|--envs-definitions"           [name]="envs_definitions"              [type]="s" )
    local -A                       __arg_num_parseargs_opt_def_=( [format]="-g|--arg-num"                    [name]="arg_num"                       [type]="i" )
    local -A                   __arg_num_min_parseargs_opt_def_=( [format]="-m|--arg-num-min"                [name]="arg_num_min"                   [type]="i" )
    local -A                   __arg_num_max_parseargs_opt_def_=( [format]="-x|--arg-num-max"                [name]="arg_num_max"                   [type]="i" )
    local -A                         __pargs_parseargs_opt_def_=( [format]="-n|--pargs"                      [name]="pargs"                         [type]="s" )
    local -A                          __opts_parseargs_opt_def_=( [format]="-p|--opts"                       [name]="opts"                          [type]="s" )
    local -A                          __envs_parseargs_opt_def_=( [format]="-i|--envs"                       [name]="envs"                          [type]="s" )
    local -A                       __verbose_parseargs_opt_def_=( [format]="-v|--verbose"                    [name]="verbose"                       [type]="f" )
    local -A                     __with_help_parseargs_opt_def_=( [format]="-h|--with-help"                  [name]="with_help"                     [type]="f" )
    local -A                    __with_usage_parseargs_opt_def_=( [format]="-w|--with-usage"                 [name]="with_usage"                    [type]="s" )
    local -A               __with_auto_usage_parseargs_opt_def_=( [format]="-x|--with-auto-usage"            [name]="with_auto_usage"               [type]="f" )
    local -A              __with_description_parseargs_opt_def_=( [format]="-d|--with-description"           [name]="with_description"              [type]="s" )
    local -A      __with_prepend_description_parseargs_opt_def_=( [format]="--with-prepend-description"      [name]="with_prepend_description"      [type]="s" )
    local -A __with_append_pargs_description_parseargs_opt_def_=( [format]="--with-append-pargs-description" [name]="with_append_pargs_description" [type]="s" )
    local -A  __with_append_opts_description_parseargs_opt_def_=( [format]="--with-append-opts-description"  [name]="with_append_opts_description"  [type]="s" )
    local -A  __with_append_envs_description_parseargs_opt_def_=( [format]="--with-append-envs-description"  [name]="with_append_envs_description"  [type]="s" )
    local -A       __with_append_description_parseargs_opt_def_=( [format]="--with-append-description"       [name]="with_append_description"       [type]="s" )
    local -A                 __with_cmd_name_parseargs_opt_def_=( [format]="-z|--with-cmd-name"              [name]="with_cmd_name"                 [type]="s" )
    local -A                           __raw_parseargs_opt_def_=( [format]="-r|--raw"                        [name]="raw"                           [type]="f" )
    local -A          __flag_default_defined_parseargs_opt_def_=( [format]="-f|--flag-default-defined"       [name]="flag_default_defined"          [type]="f" )
    local -A      __without_int_verification_parseargs_opt_def_=( [format]="-c|--without-int-verification"   [name]="without_int_verification"      [type]="f" )
    local -A                    __ubad_check_parseargs_opt_def_=( [format]="-k|--ubad-check"                 [name]="ubad_check"                    [type]="f" )

    # UBAD list for options
    local -a __parseargs_opts_definitions_=(
        __args_definitions_parseargs_opt_def_
        __opts_definitions_parseargs_opt_def_
        __envs_definitions_parseargs_opt_def_
        __arg_num_parseargs_opt_def_
        __arg_num_min_parseargs_opt_def_
        __arg_num_max_parseargs_opt_def_
        __pargs_parseargs_opt_def_
        __opts_parseargs_opt_def_
        __envs_parseargs_opt_def_
        __verbose_parseargs_opt_def_
        __with_help_parseargs_opt_def_
        __with_usage_parseargs_opt_def_
        __with_auto_usage_parseargs_opt_def_
        __with_description_parseargs_opt_def_
        __with_prepend_description_parseargs_opt_def_
        __with_append_pargs_description_parseargs_opt_def_
        __with_append_opts_description_parseargs_opt_def_
        __with_append_envs_description_parseargs_opt_def_
        __with_append_description_parseargs_opt_def_
        __with_cmd_name_parseargs_opt_def_
        __raw_parseargs_opt_def_
        __flag_default_defined_parseargs_opt_def_
        __without_int_verification_parseargs_opt_def_
        __ubad_check_parseargs_opt_def_
    )

    # -------------------------- Parse own options ----------------------------

    # Create array holding own positional arguments
    local -a __parseargs_own_args_=( "$@" )
    # Create array holding own options parsed
    local -A __parseargs_own_opts_
    # Create array holding own positional arguments parsed
    local -a __parseargs_own_pargs_
    
    # Parse own options
    parseopts                         \
        __parseargs_own_args_         \
        __parseargs_opts_definitions_ \
        __parseargs_own_opts_         \
        __parseargs_own_pargs_ ||
    {
        log_error "$__parseargs_bug_msg_ ($code_)"
        return 1
    }
    
    # Get positional arguments
    local __parseargs_args_="${__parseargs_own_pargs_[0]:-}"
    local __parseargs_parsed_="${__parseargs_own_pargs_[1]:-}"

    # Empty output array
    local -n __parseargs_parsed_ref_="${__parseargs_parsed_}"
    __parseargs_parsed_ref_=()

    # ------------------------- Check helper options --------------------------
    
    # Check if 'raw' option is passed
    local __parseargs_raw_=$( is_var_set __parseargs_own_opts_[raw] \
        && echo "raw" || echo "default" ) 

    # ---------------------------- Configure logs -----------------------------
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set __parseargs_own_opts_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs
        
    # ======================================================================= #
    # ----------------------------- Parse options --------------------------- # 
    # ======================================================================= #

    local help_requested="false"

    # Check if options' definitions has been given
    if is_var_set __parseargs_own_opts_[opts_definitions] || is_var_set __parseargs_own_opts_[with_help]; then
        
        # ------------------------ Parse caller's options -------------------------

        # Create array holding caller's options parsed
        local -A __parseargs_opts_
        
        # Compile options passed to `parseargs`
        local -a __parseargs_parseopts_opts_=()
        is_var_set __parseargs_own_opts_[verbose]                  && __parseargs_parseopts_opts_+=( -v )
        is_var_set __parseargs_own_opts_[with_help]                && __parseargs_parseopts_opts_+=( -h )
        is_var_set __parseargs_own_opts_[raw]                      && __parseargs_parseopts_opts_+=( -r )
        is_var_set __parseargs_own_opts_[flag_default_defined]     && __parseargs_parseopts_opts_+=( -f )
        is_var_set __parseargs_own_opts_[without_int_verification] && __parseargs_parseopts_opts_+=( -c )
        is_var_set __parseargs_own_opts_[ubad_check]               && __parseargs_parseopts_opts_+=( -k )
        
        # If opts' definition given, parse
        if is_var_set __parseargs_own_opts_[opts_definitions]; then

            # Parse caller's options
            parseopts ${__parseargs_parseopts_opts_[@]} --   \
                "$__parseargs_args_"                         \
                "${__parseargs_own_opts_[opts_definitions]}" \
                __parseargs_opts_                            \
                "${__parseargs_parsed_}"

        # Otherwise, create and empty one and parse
        else

            local -A __parseargs_opts_def_tmp_=()

            # Parse caller's options
            parseopts ${__parseargs_parseopts_opts_[@]} -- \
                "$__parseargs_args_"                       \
                __parseargs_opts_def_tmp_                  \
                __parseargs_opts_                          \
                "${__parseargs_parsed_}"
                
        fi

        # Get return value
        local __ret_="$?"

        # Check if help has been requested
        if [[ "$__ret_" == "5" ]]; then

            help_requested="true"

        # Else, if error occurred, throw it
        elif [[ "$__ret_" != "0" ]]; then

            log_error "Failed to parse options"
            restore_log_config_from_default_stack
            return 1

        fi

        # Write parse options to the target hash array, if given
        if is_var_set __parseargs_own_opts_[opts]; then

            # Write down the array
            copy_hash_array __parseargs_opts_ "${__parseargs_own_opts_[opts]}"

        fi

    # Else, if options are not to be parsed
    else

        # Set positional arguments to all given argumnts
        __parseargs_parsed_ref_=( "${@}" )

    fi

    # ======================================================================= #
    # -------------------------- Print help message ------------------------- # 
    # ======================================================================= #

    # Check if help needs to be printed
    if [[ "$help_requested" == "true" ]]; then
        
        # If verbose mode was requested
        if is_var_set __parseargs_own_opts_[verbose]; then

            # If custom usage string given, print it
            if is_var_set __parseargs_own_opts_[with_usage]; then

                # Get reference to the string
                local -n usage_ref="$__parseargs_own_opts_[with_usage]"
                # Print usage
                echo "$usage_ref"

            else

                local description=""
                local prog_name="$0"

                # Prepare command's description
                is_var_set __parseargs_own_opts_[with_description] && {
                    local description_name="${__parseargs_own_opts_[with_description]}"
                    description="${!description_name}"
                }
                # Prepare command's name
                is_var_set __parseargs_own_opts_[with_cmd_name] && {
                    local prog_name_name="${__parseargs_own_opts_[with_cmd_name]}"
                    prog_name="${!prog_name_name}"
                }

                # Prepare usage string
                local __parseargs_usage_string_="Usage:\n\n\t$(basename $prog_name)"
                # If options are present, add their's representation
                ( is_var_set __parseargs_own_opts_[opts_definitions] || is_var_set __parseargs_own_opts_[with_help] ) && \
                    __parseargs_usage_string_+=" [<options>...]"
                # If required positional arguments are present, add their's representation
                is_var_set __parseargs_own_opts_[pargs_definitions] && \
                    __parseargs_usage_string_+=" $(parsepargs_generate_required_arguments ${__parseargs_own_opts_[pargs_definitions]})"
                
                # Print description
                (( "${#description}" > 0 )) && echo "Description: $description"
                # Print usage string
                echo -e "$__parseargs_usage_string_"

                # Add appended description
                is_var_set __parseargs_own_opts_[with_prepend_description] && {

                    # Prepare description
                    local -n prepend_description="${__parseargs_own_opts_[with_prepend_description]}"
                    
                    # Output the string
                    echo 
                    echo -e "$prepend_description"

                }

                # Print positional arguments' description
                is_var_set __parseargs_own_opts_[pargs_definitions] && {

                    # Prepare description
                    local args_description="$(generate_pargs_description ${__parseargs_own_opts_[pargs_definitions]} $__parseargs_raw_)"
                    
                    # Output argument's description
                    echo 
                    echo "Arguments:"
                    echo 
                    echo -e "$args_description"

                }
                # Add appended pargs description
                is_var_set __parseargs_own_opts_[with_append_pargs_description] && {

                    # Prepare description
                    local -n pargs_append_description="${__parseargs_own_opts_[with_append_pargs_description]}"
                    
                    # Output the string
                    echo 
                    echo -e "$pargs_append_description"

                }

                # Print optional arguments' description
                ( is_var_set __parseargs_own_opts_[opts_definitions] || is_var_set __parseargs_own_opts_[with_help] ) && {
                    
                    local opts_description
                    
                    # If opts' definition given, generate based on them
                    if is_var_set __parseargs_own_opts_[opts_definitions]; then

                        # Prepare description
                        if is_var_set __parseargs_own_opts_[with_help]; then
                            opts_description="$(generate_opts_description ${__parseargs_own_opts_[opts_definitions]} $__parseargs_raw_ with_auto_help)"
                        else
                            opts_description="$(generate_opts_description ${__parseargs_own_opts_[opts_definitions]} $__parseargs_raw_)"
                        fi

                    # Otherwise, create and empty one and generate (in such a case --with-help must have been given)
                    else

                        local -A __parseargs_opts_def_tmp_=()

                        # Prepare description
                        opts_description="$(generate_opts_description __parseargs_opts_def_tmp_ $__parseargs_raw_ with_auto_help)"
                            
                    fi

                    # Output argument's description
                    echo 
                    echo "Options:"
                    echo 
                    echo -e "$opts_description"

                }
                # Add appended options description
                is_var_set __parseargs_own_opts_[with_append_opts_description] && {

                    # Prepare description
                    local -n opts_append_description="${__parseargs_own_opts_[with_append_opts_description]}"
                    
                    # Output the string
                    echo 
                    echo -e "$opts_append_description"

                }

                # Print environmental arguments' description
                is_var_set __parseargs_own_opts_[envs_definitions] && {
                    
                    # Prepare description
                    local envs_description="$(generate_envs_description ${__parseargs_own_opts_[envs_definitions]} $__parseargs_raw_)"

                    # Output argument's description
                    echo 
                    echo "Environment:"
                    echo 
                    echo -e "$envs_description"
                }
                # Add appended envs description
                is_var_set __parseargs_own_opts_[with_append_envs_description] && {

                    # Prepare description
                    local -n envs_append_description="${__parseargs_own_opts_[with_append_envs_description]}"
                    
                    # Output the string
                    echo 
                    echo -e "$envs_append_description"

                }

                # Add prepended description
                is_var_set __parseargs_own_opts_[with_append_description] && {

                    # Prepare description
                    local -n appended_description="${__parseargs_own_opts_[with_append_description]}"
                    
                    # Output the string
                    echo 
                    echo -e "$appended_description"

                }

            fi

            # Finalize `help` with an empty line
            echo 

        fi
        
        # Return information about 'help' option being parsed
        return 5
        
    fi

    # ======================================================================= #
    # ---------------------- Parse positional arguments --------------------- # 
    # ======================================================================= #
    
    # Check if envs' definitions has been given
    if is_var_set __parseargs_own_opts_[pargs_definitions]; then
        
        # -------------------------- Parse caller's pargs -------------------------

        # Set positional arguments to all given argumnts
        local -a __parseargs_args_=( "${__parseargs_parsed_ref_[@]}" )
        # Create array holding caller's positional args parsed
        local -A __parseargs_pargs_=()

        # Compile options passed to `parseargs`
        local __parseargs_parsepargs_opts_=()
        is_var_set __parseargs_own_opts_[arg_num]                  && __parseargs_parsepargs_opts_+=( -g )
        is_var_set __parseargs_own_opts_[arg_num_min]              && __parseargs_parsepargs_opts_+=( -m )
        is_var_set __parseargs_own_opts_[arg_num_max]              && __parseargs_parsepargs_opts_+=( -x )
        is_var_set __parseargs_own_opts_[verbose]                  && __parseargs_parsepargs_opts_+=( -v )
        is_var_set __parseargs_own_opts_[flag_default_defined]     && __parseargs_parsepargs_opts_+=( -f )
        is_var_set __parseargs_own_opts_[raw]                      && __parseargs_parsepargs_opts_+=( -r )
        is_var_set __parseargs_own_opts_[without_int_verification] && __parseargs_parsepargs_opts_+=( -c )
        is_var_set __parseargs_own_opts_[ubad_check]               && __parseargs_parsepargs_opts_+=( -k )

        # Parse caller's pargs
        parsepargs ${__parseargs_parsepargs_opts_[@]} --  \
            __parseargs_args_                             \
            "${__parseargs_own_opts_[pargs_definitions]}" \
            __parseargs_pargs_                            ||
        {
            log_error "Failed to parse positional arguments"
            restore_log_config_from_default_stack
            return 1
        }

        # Write parsed pargs to the target hash array, if given
        if is_var_set __parseargs_own_opts_[pargs]; then

            # Write down the array
            copy_hash_array __parseargs_pargs_ "${__parseargs_own_opts_[pargs]}"
            
        fi

    fi

    # ======================================================================= #
    # --------------------- Parse environmental arguments ------------------- # 
    # ======================================================================= #

    # Check if envs' definitions has been given
    if is_var_set __parseargs_own_opts_[envs_definitions]; then
        
        # -------------------------- Parse caller's envs --------------------------

        # Create array holding caller's envs parsed
        local -A __parseargs_envs_

        # Compile options passed to `parseargs`
        local __parseargs_parseenvs_opts_=()
        is_var_set __parseargs_own_opts_[verbose]                  && __parseargs_parseenvs_opts_+=( -v )
        is_var_set __parseargs_own_opts_[raw]                      && __parseargs_parseenvs_opts_+=( -r )
        is_var_set __parseargs_own_opts_[flag_default_defined]     && __parseargs_parseenvs_opts_+=( -f )
        is_var_set __parseargs_own_opts_[without_int_verification] && __parseargs_parseenvs_opts_+=( -c )

        # Parse caller's envs
        parseenvs ${__parseargs_parseenvs_opts_[@]} --   \
            "${__parseargs_own_opts_[envs_definitions]}" \
            __parseargs_envs_                            ||
        {
            log_error "Failed to parse envs"
            restore_log_config_from_default_stack
            return 1
        }

        # Write parsed envs to the target hash array, if given
        if is_var_set __parseargs_own_opts_[envs]; then

            # Write down the array
            copy_hash_array __parseargs_envs_ "${__parseargs_own_opts_[envs]}"
            
        fi

    fi

    # ======================================================================= #

    restore_log_config_from_default_stack
    return 0    
}

# ========================================================= Helper aliases ========================================================= #


# ---------------------------------------------------------------------------------------
# @brief Common idiom for parsing arguments of the script using `parseargs`. Aim of this
#   alias is to limit boilerplate code required by the API. It is aimed to be used in
#   scripts rather than bash functions as it intoduces a lot of names in the caller's 
#   namespace
# 
# @environment
#
#           cmd_name  if defined, `parseargs` will be called with the 
#                     '--with-cmd-name="cmd_name"' option
#    cmd_description  if defined, `parseargs` will be called with the 
#                     '--with-description="cmd_description"' option
#          *_opt_def  hash arrays containing descriptors of script's optional arguments;
#                     if any name matching the pattern is defined in the namespace, the
#                     `parseargs` will be called with the '--opts-definitions' option
#                     passed with the name of the auto-generated UBAD list for options
#                     (symbols starting with an underscore are discarded)
#          *_env_def  hash arrays containing descriptors of script's environmental arguments;
#                     if any name matching the pattern is defined in the namespace, the
#                     `parseargs` will be called with the '--envs-definitions' option
#                     passed with the name of the auto-generated UBAD list for envs
#                     (symbols starting with an underscore are discarded)
#         *_parg_def  hash arrays containing descriptors of script's positional arguments;
#                     if any name matching the pattern is defined in the namespace, the
#                     `parseargs` will be called with the '--pargs-definitions' option
#                     passed with the name of the auto-generated UBAD list for positional
#                     arguments
#                     (symbols starting with an underscore are discarded)
#   opts_description  if defined, *_opt_def UBAD tables will be automatically extended 
#                     with [help] fields containing strings given in this hash array. Key
#                     to the description shall be a value of the [name] field of the UBAD
#                     table
#   envs_description  if defined, *_env_def UBAD tables will be automatically extended 
#                     with [help] fields containing strings given in this hash array. Key
#                     to the description shall be a value of the [name] field of the UBAD
#                     table
#  pargs_description  if defined, *_parg_def UBAD tables will be automatically extended 
#                     with [help] fields containing strings given in this hash array. Key
#                     to the description shall be a value of the [name] field of the UBAD
#                     table
#     PARSEARGS_OPTS  list of additional options passed to the `parseargs` call (overrides)
#                     options passed by the alias
#                  *  as the alias calls `parseargs` directly, the variables constituting
#                     environment of the function itself will be forwarded
# @provides
#
#                ret  return code from the `parseargs`
#      args_to_parse  list containing arguments of the calling script/function
#               opts  (defined when any name matching '*_opt_def' pattern is defined)
#                     hash array that the script's options are parsed into
#           opts_def  (defined when any name matching '*_opt_def' pattern is defined) array of
#                     UBAD tables containing definitions of optional parameters
#               envs  (defined when any name matching '*_env_def' pattern is defined)
#                     hash array that the script's environmental arguments are parsed into
#           envs_def  (defined when any name matching '*_env_def' pattern is defined) array of
#                     UBAD tables containing definitions of environmental parameters
#              pargs  (defined when any name matching '*_parg_def' pattern is defined)
#                     hash array that the script's positional arguments are parsed into
#          pargs_def  (defined when any name matching '*_parg_def' pattern is defined) array of
#                     UBAD tables containing definitions of positional parameters
#             parsed  array of parsed positional arguments in order
#
# @note When UBAD list is automatically generated form *_opt_def/*_env_def/*_parg_def
#    arays, the names are sorted in the ortographical order (as the result of 
#    `declare -A` is). For this reason UBAD tasbles' names should be named correctly.
#    The required order may be implemented by preprending them with subsequent alphabet's
#    letters.
# ---------------------------------------------------------------------------------------
alias parse_arguments='

# --------------------------- Prepare arguments ---------------------------

# Parse arguments to a named array
local -a args_to_parse=( "$@" )
# Prepare array for parsed arguments
local -a parsed

# Prepare array for `parseargs` options
local -a __parseargs_options__=()

# Enable word splitting in the local context
localize_word_splitting
push_stack "$IFS"
enable_word_splitting

# ------------------------- Prepare help generator ------------------------

# Add command name
if is_var_set cmd_name; then
    __parseargs_options__+=( "--with-cmd-name=cmd_name" )
fi

# Add command description
if is_var_set cmd_description; then
    __parseargs_options__+=( "--with-description=cmd_description" )
fi

# --------------------------- Prepare optionals ---------------------------

# If UBAD tables for optionals are defined
if declare -A | grep -oE -- " [[:alpha:]][[:alnum:]_]*_opt_def" > /dev/null; then

    # Create UBAD list for options
    local -a opts_def=(
        $(declare -A | grep -oE -- " [[:alpha:]][[:alnum:]_]*_opt_def")
    )

    # If standalone descriptions given, parse them
    if is_hash_array opts_description || [[ $(get_entity_type opts_description) == "n" ]]; then

        local __opt_def_

        # Iterate over UBAD tales and parse descriptions
        for __opt_def_ in "${opts_def[@]}"; do

            # Get reference to the table
            local -n __opt_def_ref_="$__opt_def_"
            # Get options name
            local __opt_name_="${__opt_def_ref_[name]}"
            # Parse description
            if is_var_set opts_description[$__opt_name_]; then
                __opt_def_ref_[help]="${opts_description[$__opt_name_]}"
            fi

        done

    fi

    # Prepare container for parsed options (out)
    local -A opts

    # Add options to the call
    __parseargs_options__+=( --opts-definitions=opts_def )
    __parseargs_options__+=( --opts=opts                 )

fi

# ------------------------- Prepare environmentals ------------------------

# If UBAD tables for optionals are defined
if declare -A | grep -oE -- " [[:alpha:]][[:alnum:]_]*_env_def" > /dev/null; then

    # Create UBAD list for envs
    local -a envs_def=(
        $(declare -A | grep -oE -- " [[:alpha:]][[:alnum:]_]*_env_def")
    )

    # If standalone descriptions given, parse them
    if is_hash_array envs_description || [[ $(get_entity_type envs_description) == "n" ]]; then

        local __env_def_

        # Iterate over UBAD tales and parse descriptions
        for __env_def_ in "${envs_def[@]}"; do

            # Get reference to the table
            local -n __env_def_ref_="$__env_def_"
            # Get envs name
            local __env_name_="${__env_def_ref_[name]}"
            # Parse description
            if is_var_set envs_description[$__env_name_]; then
                __env_def_ref_[help]="${envs_description[$__env_name_]}"
            fi

        done

    fi

    # Prepare container for parsed envs (out)
    local -A envs

    # Add options to the call
    __parseargs_options__+=( --envs-definitions=envs_def )
    __parseargs_options__+=( --envs=envs                 )

fi

# -------------------------- Prepare positionals --------------------------

# If UBAD tables for positionals are _parg_def
if declare -A | grep -oE -- " [[:alpha:]][[:alnum:]_]*_parg_def" > /dev/null; then

    # Create UBAD list for positionals
    local -a pargs_def=(
        $(declare -A | grep -oE -- " [[:alpha:]][[:alnum:]_]*_parg_def")
    )

    # If standalone descriptions given, parse them
    if is_hash_array pargs_description || [[ $(get_entity_type pargs_description) == "n" ]]; then

        local __parg_def_

        # Iterate over UBAD tales and parse descriptions
        for __parg_def_ in "${pargs_def[@]}"; do

            # Get reference to the table
            local -n __parg_def_ref_="$__parg_def_"
            # Get parg name
            local __parg_name_="${__parg_def_ref_[name]}"
            # Parse description
            if is_var_set pargs_description[$__parg_name_]; then
                __parg_def_ref_[help]="${pargs_description[$__parg_name_]}"
            fi

        done

    fi

    # Prepare container for parsed positionals (out)
    local -A pargs

    # Add options to the call
    __parseargs_options__+=( --pargs-definitions=pargs_def )
    __parseargs_options__+=( --pargs=pargs                 )

fi

# --------------------------- Add custom options --------------------------

# If custom options are defined
if is_var_set PARSEARGS_OPTS; then

    local __custom_opt_

    # Iterate over options and add them to the list
    for __custom_opt_ in "${PARSEARGS_OPTS[@]}"; do
        __parseargs_options__+=( "${__custom_opt_}" )
    done

fi

# ---------------------------- Parse arguments ----------------------------

# Restore word-splitting configuration
pop_stack IFS

# Parse options
parseargs ${__parseargs_options__[@]} args_to_parse parsed && ret=$? || ret=$?
'
