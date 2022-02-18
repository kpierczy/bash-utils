#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 2:37:47 pm
# @modified Friday, 18th February 2022 6:57:38 pm
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
#    @c 1 if function sufferred from the bug \n
#    @c 2 if invalid argument has been passed \n
#    @c 3 if argument(s) of the wrong type has been given \n
#    @c 4 if invalid UBAD list has been given
#    @c 5 if '-h|--help' option has been parsed \n
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
#  -e HARR, --envs-definitions=HARR  name of the 'envs-definitions' UBAD list
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
#  -h,                  --with-help  if set, the UBAD table for the help option (with 
#                                    standard -h|--help format) will be appended to the
#                                    UBAD list 
#  -w STR,         --with-usage=STR  usage string to be printed when the --verbose 
#                                    switch is set
#  -x,            --with-auto-usage  if set, the automatic usage message will be 
#                                    printed, when the --verbose switch is set 
#                                    (overwritten by --with-usage)
#  -d STR,   --with-description=STR  description string to be printed in the usage 
#                                    string
#  -z STR,      --with-cmd-name=STR  name of the command to be printed in the usage
#                                    message (default: $0)
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
# ---------------------------------------------------------------------------------------
function parseargs() {
    
    local LOG_CONTEXT="$__parseargs_log_context_"

    # ---------------------------- Define options -----------------------------
    
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
    local -A                 __with_help_parseargs_opt_def_=( [format]="-h|--with-help"                 [name]="with_help"                 [type]="s" )
    local -A                __with_usage_parseargs_opt_def_=( [format]="-w|--with-usage"                [name]="with_usage"                [type]="s" )
    local -A           __with_auto_usage_parseargs_opt_def_=( [format]="-x|--with-auto-usage"           [name]="with_auto_usage"           [type]="f" )
    local -A          __with_description_parseargs_opt_def_=( [format]="-d|--with-description"          [name]="with_description"          [type]="s" )
    local -A             __with_cmd_name_parseargs_opt_def_=( [format]="-z|--with-cmd-name"             [name]="with_cmd_name"             [type]="s" )
    local -A                       __raw_parseargs_opt_def_=( [format]="-r|--raw"                       [name]="raw"                       [type]="f" )
    local -A      __flag_default_defined_parseargs_opt_def_=( [format]="-f|--flag-default-defined"      [name]="flag_default_defined"      [type]="f" )
    local -A  __without_int_verification_parseargs_opt_def_=( [format]="-c|--without-int-verification"  [name]="without_int_verification"  [type]="f" )
    local -A                __ubad_check_parseargs_opt_def_=( [format]="-k|--ubad-check"                [name]="ubad_check"                [type]="f" )

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
        __with_help_parseargs_opt_def_
        __with_usage_parseargs_opt_def_
        __with_auto_usage_parseargs_opt_def_
        __with_description_parseargs_opt_def_
        __with_cmd_name_parseargs_opt_def_
        __raw_parseargs_opt_def_
        __flag_default_defined_parseargs_opt_def_
        __without_int_verification_parseargs_opt_def_
        __without_path_verification_parseargs_opt_def_
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
    local __parseargs_args_="${__parseopts_own_posargs_[0]:-}"
    local __parseargs_pargs_="${__parseopts_own_posargs_[1]:-}"

    # Empty output array
    local -n __parseargs_pargs_ref_="${__parseargs_pargs_}"
    __parseargs_pargs_ref_=()

    # Set positional arguments to those parse by `parseopts` for convinience
    eval "set -- ${__parseargs_own_pargs_[@]}"

    # ---------------------------- Configure logs -----------------------------

    local LOG_CONTEXT="$__parseargs_log_context_"
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set __parseopts_own_options_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # ======================================================================= #
    # ----------------------------- Parse options --------------------------- # 
    # ======================================================================= #

    local help_requested="false"

    # Check if options' definitions has been given
    if is_var_set __parseargs_own_opts_[opts_definitions]; then
        
        # ------------------------ Parse caller's options -------------------------

        # Create array holding caller's positional arguments
        local -a __parseargs_args_=( "$@" )
        # Create array holding caller's options parsed
        local -A __parseargs_opts_

        # Compile options passed to `parseargs`
        local __parseargs_parseopts_opts_=""
        is_var_set __parseargs_own_opts_[verbose]                  && __parseargs_parseopts_opts_+=" -v"
        is_var_set __parseargs_own_opts_[with_help]                && __parseargs_parseopts_opts_+=" -h"
        is_var_set __parseargs_own_opts_[raw]                      && __parseargs_parseopts_opts_+=" -r"
        is_var_set __parseargs_own_opts_[flag_default_defined]     && __parseargs_parseopts_opts_+=" -f"
        is_var_set __parseargs_own_opts_[without_int_verification] && __parseargs_parseopts_opts_+=" -c"
        is_var_set __parseargs_own_opts_[ubad_check]               && __parseargs_parseopts_opts_+=" -k"

        # Parse caller's options
        parseopts "$__parseargs_parseopts_opts_" --      \
            __parseargs_args_                            \
            "${__parseargs_own_opts_[opts_definitions]}" \
            __parseargs_opts_                            \
            "${__parseargs_pargs_}"                      ||
        {
            log_error "Failed to parse options"
            restore_log_config_from_default_stack
            return 1
        }

        # Check if help has been requested
        if [[ "$?" == "5" ]]; then
            help_requested="true"
        fi

        # Write parse options to the target hash array, if given
        if is_var_set __parseargs_own_opts_[opts]; then

            # Get reference to the array
            local __parseargs_opts_ref_="${__parseargs_own_opts_[opts]}"
            # Write down the array
            copy_hash_array __parseargs_opts_ __parseargs_opts_ref_
            
        fi

        # Set positional arguments to those parse by `parseopts` for convinience
        eval "set -- ${__parseargs_pargs_ref_[@]}"

    # Else, if options are not be parsed
    else

        # Set positional arguments to all given argumnts
        __parseargs_pargs_ref_=( "${@}" )

    fi

    # ======================================================================= #
    # -------------------------- Print help message ------------------------- # 
    # ======================================================================= #

    # Check if help needs to be printed
    if [[ "$help_requested" == "true" ]] && is_var_set __parseargs_own_opts_[verbose]; then
        
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
            is_var_set __parseargs_own_opts_[with_description] && description="${__parseargs_own_opts_[with_description]}"
            # Prepare command's name
            is_var_set __parseargs_own_opts_[with_cmd_name]    && prog_name="${__parseargs_own_opts_[with_cmd_name]}"

            # Prepare usage string
            local __parseargs_usage_string_="Usage: $prog_name"
            # If options are present, add their's representation
            is_var_set __parseargs_own_opts_[opts_definitions] && __parseargs_usage_string_+=" [OPTIONS]"
            # If required positional arguments are present, add their's representation
            is_var_set __parseargs_own_opts_[args_definitions] && \
                __parseargs_usage_string_+=" $(parsepargs_generate_required_arguments ${__parseargs_own_opts_[args_definitions]})"
            # If non-required positional arguments are present, add their's representation as '...'
            parsepargs_has_non_required_arguments ${__parseargs_own_opts_[args_definitions]} && __parseargs_usage_string_+=" ..."
            
            # Print description
            (( "${#description}" > 0 )) && echo "Description: $description"
            # Print usage string
            echo -e "$__parseargs_usage_string_"
            echo 

            # Print positional arguments' description
            is_var_set __parseargs_own_opts_[args_definitions] && {

                # Prepare description
                local args_description="$(generate_pargs_description ${__parseargs_own_opts_[args_definitions]})"

                # Output argument's description
                echo "Arguments:"
                echo 
                echo -e "$args_description"
                echo 

            }
            # Print optional arguments' description
            is_var_set __parseargs_own_opts_[opts_definitions] && {
                
                local opts_description
                
                # Prepare description
                if is_var_set __parseargs_own_opts_[with_help]; then
                    opts_description="$(generate_opts_description ${__parseargs_own_opts_[opts_definitions]}) with_auto_help"
                else
                    opts_description="$(generate_opts_description ${__parseargs_own_opts_[opts_definitions]})"
                fi

                # Output argument's description
                echo "Options:"
                echo 
                echo -e "$opts_description"
                echo 

            }
            # Print environmental arguments' description
            is_var_set __parseargs_own_opts_[envs_definitions] && {
                
                # Prepare description
                local envs_description="$(generate_envs_description ${__parseargs_own_opts_[envs_definitions]})"

                # Output argument's description
                echo "Environment:"
                echo 
                echo -e "$envs_description"
            }

        fi
        
    fi

    # ======================================================================= #
    # ---------------------- Parse positional arguments --------------------- # 
    # ======================================================================= #

    # ---------------- Verify number of positional arguments ------------------

    # Get number of positional arguments
    local pos_args_num="${#__parseargs_pargs_ref_[@]}"

    # If required number of positional arguments given
    if is_var_defined __parseargs_own_opts_[arg_num]; then

        # Check if actual number of arguments matched
        if (("$pos_args_num" != "${__parseargs_own_opts_[arg_num]}")); then
            log_error "($pos_args_num) positional arguments has been given when (${__parseargs_own_opts_[arg_num]}) is required"
            restore_log_config_from_default_stack
            return 2
        fi

    # Else
    else

        # If maximal number of positional arguments given
        if is_var_defined __parseargs_own_opts_[arg_num_min]; then

            # Check if actual number of arguments is NOT lesser than minimal
            if (("$pos_args_num" < "${__parseargs_own_opts_[arg_num_min]}")); then
                log_error "($pos_args_num) positional arguments has been given when at least (${__parseargs_own_opts_[arg_num_min]}) is required"
                restore_log_config_from_default_stack
                return 2
            fi
            
        fi

        # If minimal number of positional arguments given
        if is_var_defined __parseargs_own_opts_[arg_num_max]; then

            # Check if actual number of arguments is NOT greater than minimal
            if (("$pos_args_num" > "${__parseargs_own_opts_[arg_num_max]}")); then
                log_error "($pos_args_num) positional arguments has been given when at most (${__parseargs_own_opts_[arg_num_max]}) is required"
                restore_log_config_from_default_stack
                return 2
            fi
            
        fi
        
    fi

    # --------------------- Parse positional arguments ------------------------

    # ======================================================================= #
    # --------------------- Parse environmental arguments ------------------- # 
    # ======================================================================= #

    # Check if envs' definitions has been given
    if is_var_set __parseargs_own_opts_[envs_definitions]; then
        
        # -------------------------- Parse caller's envs --------------------------

        # Create array holding caller's envs parsed
        local -A __parseargs_envs_

        # Compile options passed to `parseargs`
        local __parseargs_parseenvs_opts_=""
        is_var_set __parseargs_own_opts_[verbose]                  && __parseargs_parseenvs_opts_+=" -v"
        is_var_set __parseargs_own_opts_[raw]                      && __parseargs_parseenvs_opts_+=" -r"
        is_var_set __parseargs_own_opts_[flag_default_defined]     && __parseargs_parseenvs_opts_+=" -f"
        is_var_set __parseargs_own_opts_[without_int_verification] && __parseargs_parseenvs_opts_+=" -c"

        # Parse caller's envs
        parseenvs "$__parseargs_parseenvs_opts_" --      \
            "${__parseargs_own_opts_[envs_definitions]}" \
            __parseargs_envs_                            ||
        {
            log_error "Failed to parse envs"
            restore_log_config_from_default_stack
            return 1
        }

        # Write parsed envs to the target hash array, if given
        if is_var_set __parseargs_own_opts_[envs]; then

            # Get reference to the array
            local __parseargs_envs_ref_="${__parseargs_own_opts_[envs]}"
            # Write down the array
            copy_hash_array __parseargs_envs_ __parseargs_envs_ref_
            
        fi

    fi

    # ======================================================================= #

    restore_log_config_from_default_stack
    return 0    
}

