#!/usr/bin/env bash
# ====================================================================================================================================
# @file     arguments_old.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 12:25:13 am
# @modified Sunday, 21st November 2021 4:34:29 pm
# @project  bash-utils
# @brief
#    
#    Set of tools related to parsing arguments by the bash functions and scripts
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependencies
source $BASH_UTILS_HOME/lib/processing/variables.bash

# ========================================================= Helper aliases ========================================================= #

# -------------------------------------------------------------------
# @brief Helper macro used inside the `parseargs` function. Echoes
#    content of the USAGE variable only if the verbose mode is set
#    (i.e. _options_[verbose] entity is defined) and if the USAGE
#    variable itself is defined
# -------------------------------------------------------------------
alias __echo_usage_if_verbose='
    is_var_set_non_empty _pa_options_[verbose] && 
    is_var_set_non_empty USAGE &&
    echo "$USAGE"
'

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Parses and verifies command-line arguments passed to the 
#    script performing series of common routines:
#
#         - prints error logs to the stdout if invalid
#           options passed
#         - prints usage message, if the `--help` option
#           parsed
#         - verifies whether required number of positional
#           arguments has been passed
#         - verifies values of the passed arguments
#         - verifies values of the passed options
#
# @param args 
#    name of the array containing arguments to be parsed
# @param posargs (out)
#    name of the array that positional arguments has to be parsed
#    into
#
# @returns 
#    @c 0 if no error occurred \n
#    @c 1 if arguments parsing/verification failed \n
#    @c 2 if usage message was requested with '-h, --help' 
#         option
#
# @options
# 
# -d|--options-defs name of the array holding options to be parsed 
#                   in shape 
# 
#                    defs=(
#                        '-o|option1',o_flag,f # Flag options
#                        '-s|option2',s_var    # Keyword options
#                    )
#
#                   Format of the single record in the @p defs array
#                   is as follows: opt_name, var_name, [f]. 'opt_name'
#                   is string describing command-line shape of the 
#                   option. Using '|' one can define both short and
#                   long name. 'var_name' is name of the record that
#                   the value of the option will be written under in
#                   the @p opts hash array (if parsed). Optional 'f'
#                   flag marks that the option is a flag (valued in 
#                   the @p opts array with '1', if parsed)
#
#                   If option is not set, it is assumed that the
#                   script takes only positonal arguments
#
# -o|--options-dst  name of the hash array that options has to be 
#                   parsed into (default: options). This option
#                   is taken into account only if the --options-defs
#                   is passed
#
#     -v|--verbose  if set, function will proceed verbosely printing
#                   error logs in case of the parsing error 
#
# @environment
#
#          USAGE  If set it's content will be printed when the 
#                 `-h, --help` is parsed (assuming the definition
#                 of the options is present in the @p defs array)
#
#        ARG_NUM  Number of arguments required by the function. 
#                 If set, function will return 1 when the number of 
#                 parsed positional arguments differs
#    ARG_NUM_MIN  Minimal number of arguments. If set - and no 
#                 ARG_NUM is set - function will return 1 when the 
#                 number of parsed positional arguments is smaller
#    ARG_NUM_MAX  Maximum number of arguments. If set - and no 
#                 ARG_NUM is set - function will return 1 when the 
#                 number of parsed positional arguments is greater
#
#  ARGn_VARIANTS  If set, a name of the list holding valid values for
#                 the nth positional argument (n in range 1...)
#       ARGn_MIN  If set, a minimal value of the nth positional 
#                 argument (n in range 1...)
#       ARGn_MAX  If set, a maximal value of the nth positional 
#                 argument (n in range 1...)
#
#     x_VARIANTS  If set, a name of the list holding valid values for
#                 the x option (where x is a name of the key
#                 in the @p options hash array where the option
#                 is parsed into)
#          x_MIN  If set, a minimal value of the x option (where 
#                 x is a name of the key in the @p options hash
#                 array where the option is parsed into)
#          x_MAX  If set, a maximal value of the x option (where 
#                 x is a name of the key in the @p options hash
#                 array where the option is parsed into)
#
#    LOG_CONTEXT  contex of the printed logs
#    
# @reserved 
#
#      _pa_args_            _callers_args_
#      _pa_posargs_         _callers_posargs_
#      _pa_posargs_         _callers_posargs_
#      _pa_options_         _callers_options_
#      _pa_opt_definitions_ _callers_opt_definitions_
#
#   These variables names are used inside the function and
#   should not be used by the calling context as a source/destination
#   of/for the parsed arguments to avoid missreference
#
# @example
#
#      # Define usage message
#      USAGE=...
#
#      # Parse options into an array
#      local args=( "$@" )
# 
#      # Define some options
#      local -a opt_definitions=(
#         '-h|--help',help,f
#         '-s|--some-option',some,f
#         '-o|--some-other-option',some_other
#      )
#
#      # Prepare arrays for the output of the `parseargs` function
#      local -a posargs
#      local -A options
#
#      # Prepare positional arguments' constaints
#      ARG_NUM=2
#      ARG1_VARIANTS=( variant1 variant2 variant3 )
#      ARG2_MIN=0
#      ARG2_MAX=100
#
#      # Prepare options' constaints
#      some_VARIANTS=( some_variant1 some_variant2 )
#      some_other_MIN=15
#      some_other_MAX=2000
#
#      # Let the function parse and validate your arguments
#      parseargs                        \
#        --verbose                      \
#        --options-defs=opt_definitions \
#        --options-dst=options          \
#        args                           \
#        posargs || return 1
# 
# -------------------------------------------------------------------
function parseargs() {

    # Arguments
    # local -n _pa_args_
    # local -n _pa_posargs_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a _pa_opt_definitions_=(
        '-d|--options-defs',opt_definitions
        '-o|--options-dst',options_dest
        '-v|--verbose',verbose,f
    )
    
    # Parse arguments to a named array
    local -a _pa_args_=( "$@" )

    # Prepare names hash arrays for positional arguments and parsed options
    local -a _pa_posargs_
    local -A _pa_options_

    # Parse options
    parseopts _pa_args_ _pa_opt_definitions_ _pa_options_ _pa_posargs_ || return 1

    # Parse arguments
    local -n _callers_args_="${_pa_posargs_[0]}"
    local -n _callers_posargs_="${_pa_posargs_[1]}"

    # Parse options
    if is_var_set_non_empty _pa_options_[opt_definitions]; then
        local -n _callers_opt_definitions_="${_pa_options_[opt_definitions]}"
        local -n _callers_options_="${_pa_options_[options_dest]:-options}"
    fi
    
    # ----------------- Configure logs ----------------   

    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set _pa_options_[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # -------------------------------------------------
    
    # If options' definitions given
    if is_var_set_non_empty _pa_options_[opt_definitions]; then
    
        # Parse options
        parseopts _callers_args_ _callers_opt_definitions_ _callers_options_ _callers_posargs_ || {

            # Echo error with usage message
            log_error "Invalid usage"
            __echo_usage_if_verbose
            # Restore logging configuration
            restore_log_config_from_default_stack
            # Return error
            return 1
            
        }

        # Display usage message, if requested
        is_var_set _callers_options_[help] && {
            
            # Echo usage message
            __echo_usage_if_verbose
            # Restore logging configuration
            restore_log_config_from_default_stack
            # Return status
            return 2

        }


    # Else, if no options' definitions were given
    else

        # Set positional arguments to be same as arguments
        _callers_posargs_=( "${_callers_args_[@]}" )

    fi

    # ----- Verify number of positional arguments -----

    # Check if required number of arguments was given
    if is_var_set_non_empty ARG_NUM; then
        
        (( ${#_callers_posargs_[@]} == $ARG_NUM )) || {
            
            # Echo error with usage message
            log_error "Wrong number of arguments"
            __echo_usage_if_verbose
            # Restore logging configuration
            restore_log_config_from_default_stack
            # Return error
            return 1
            
        }

    # Check if number of arguments lies in the valid range
    else

        # Check if minimal number of arguments has been given
        if is_var_set_non_empty ARG_NUM_MIN; then
            (( ${#_callers_posargs_[@]} >= $ARG_NUM_MIN )) || {
            
                # Echo error with usage message
                log_error "Too fiew arguments"
                __echo_usage_if_verbose
                # Restore logging configuration
                restore_log_config_from_default_stack
                # Return error
                return 1

            }
        fi

        # Check if maximal number of arguments has been given
        if is_var_set_non_empty ARG_NUM_MAX; then
            (( ${#_callers_posargs_[@]} <= $ARG_NUM_MAX )) || {
            
                # Echo error with usage message
                log_error "Too many arguments"
                __echo_usage_if_verbose
                # Restore logging configuration
                restore_log_config_from_default_stack
                # Return error
                return 1

            }
        fi

    fi

    # ---------- Verify positional arguments ----------

    local arg_idx_
    local arg_idx_conjugated_
    local i_
    
    # Validate positional arguments
    for i_ in "${!_callers_posargs_[@]}"; do

        # Get index of the argument
        arg_idx_=$(( $i_ + 1 ))

        # Conjugation argument's number
        arg_idx_conjugated_=$(inflect_numeral $arg_idx_)

        # If an argument is allowed to have only a predefined values
        if is_var_set_non_empty ARG${arg_idx_}_VARIANTS; then
        
            # Check if argument has an anticipated value
            is_array_element ARG${arg_idx_}_VARIANTS "${_callers_posargs_[$i_]}" || {

                # Echo error with usage message
                log_error \
                    "Invalid value of the $arg_idx_conjugated_ argument (${_callers_posargs_[$i_]})" \
                    "Valid values are: [ $(print_array ARG${arg_idx_}_VARIANTS -s ', ') ]"
                __echo_usage_if_verbose
                # Restore logging configuration
                restore_log_config_from_default_stack
                # Return error
                return 1

            }

        # Else, check if argument is in a predefined range
        else 

            local arg_min_val_ref_="ARG${arg_idx_}_MIN"
            local arg_max_val_ref_="ARG${arg_idx_}_MAX"

            # Check if argument's value is not lesser than a minimal one
            if is_var_set_non_empty "$arg_min_val_ref_"; then
                [[ "${_callers_posargs_[$i_]}" -ge "${!arg_min_val_ref_}" ]] || {
                        
                    # Echo error with usage message
                    log_error \
                        "$arg_idx_conjugated_ positional argument too small (${_callers_posargs_[$i_]})" \
                        "Minimal value is (${!arg_min_val_ref_})"
                    __echo_usage_if_verbose
                    # Restore logging configuration
                    restore_log_config_from_default_stack
                    # Return error
                    return 1

                }
            fi

            # Check if argument's value is not greater than a maximal one
            if is_var_set_non_empty "$arg_max_val_ref_"; then
                [[ "${_callers_posargs_[$i_]}" -ge "${!arg_max_val_ref_}" ]] || {

                    # Echo error with usage message
                    log_error \
                        "$arg_idx_conjugated_ positional argument too large (${_callers_posargs_[$i_]})" \
                        "Maximal value is (${!arg_max_val_ref_})"
                    __echo_usage_if_verbose
                    # Restore logging configuration
                    restore_log_config_from_default_stack
                    # Return error
                    return 1

                }
            fi
            
        fi

    done

    # ----------- Verify optional arguments -----------

    # Verify options only if options' definitions was given
    is_var_set_non_empty _pa_options_[opt_definitions] && {

        local _callers_opt_

        # Validate optional arguments
        for _callers_opt_ in "${!_callers_options_[@]}"; do
            
            # Get name of the option typed by the user in case of reporting an error
            local _callers_opt_name_=$(get_option_name _callers_args_ _callers_opt_definitions_ _callers_opt_)
            # Check if error occurred (should not happen, as the option was sucesfully parsed by `parseopts`)
            [[ $? == 0 ]] || {

                # Echo error message
                log_error \
                    "Critial error occurred `get_option_name` was not able to find an option" \
                    "already parsed byt `parseopts`. Please report a bug."
                # Return error
                return 1
                
            }

            # If an option is allowed to have only a predefined values
            if is_var_set_non_empty "${_callers_opt_}_VARIANTS"; then
            
                # Check if argument has an anticipated value
                is_array_element "${_callers_opt_}_VARIANTS" "$_callers_opt_" || {

                    # Echo error with usage message
                    log_error \
                        "Invalid value of the $_callers_opt_name_ option (${_callers_options_[$_callers_opt_]})" \
                        "Valid values are: [ $(print_array ${_callers_opt_}_VARIANTS -s ', ') ]"
                    __echo_usage_if_verbose
                    # Restore logging configuration
                    restore_log_config_from_default_stack
                    # Return error
                    return 1
                    
                }

            # Else, check if an option is in a predefined range
            else     

                local opt_min_val_ref_="${_callers_opt_}_MIN"
                local opt_max_val_ref_="${_callers_opt_}_MAX"

                # Check if options's value is not lesser than a minimal one
                if is_var_set_non_empty "$opt_min_val_ref_"; then
                    [[ "${_callers_opt_}" -ge "${!opt_min_val_ref_}" ]] || {
                            
                        # Echo error with usage message
                        log_error \
                            "$_callers_opt_name_ option too small (${_callers_options_[$_callers_opt_]})" \
                            "Minimal value is (${!opt_min_val_ref_})"
                        __echo_usage_if_verbose
                        # Restore logging configuration
                        restore_log_config_from_default_stack
                        # Return error
                        return 1

                    }
                fi

                # Check if options's value is not greater than a maximal one
                if is_var_set_non_empty "$opt_max_val_ref_"; then
                    [[ "${_callers_opt_}" -ge "${!opt_max_val_ref_}" ]] || {

                        # Echo error with usage message
                        log_error \
                            "$_callers_opt_name_ option too large (${_callers_options_[$_callers_opt_]})" \
                            "Maximal value is (${!opt_max_val_ref_})"
                        __echo_usage_if_verbose
                        # Restore logging configuration
                        restore_log_config_from_default_stack
                        # Return error
                        return 1
                        
                    }
                fi

            fi

        done

    }

    # -------------------------------------------------

    # Restore logging configuration
    restore_log_config_from_default_stack
    # If no error found, return success
    return 0

}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Common idiom for parsing arguments of the function/script
#    taking some options. This is an extended version of the 
#    `parse_options` alias. For newer designs it is recommended to 
#    use `parse_arguments` instead. Had said that the 
#    `parse_arguments` alias is still handy in the implementation
#    of simpler or more generic functions/scripts that does not 
#    need additional functionalities provided by the `parseargs`
#    function
#
#    Alias gathers arguments passed to the calling context (function
#    or script) into the @var args array. If the context defines
#    a @var opt_definitions array containing definitions of the 
#    options, then body of the alias will try to parse expected
#    options from the @var args array using `parseopts` function. If
#    it fails, alias will call `return 1`. Otherwise the results
#    will be placed in the @var posargs list (positional arguments)
#    and the @var options hash array (parsed options)
# 
#    Additionally alias can provide a more declarative to parse 
#    positional arguments. If the calling context defines the 
#    @var arguments array. This array should contain a list of names
#    of variables that will hold positional arguments when the alias
#    exits sucesfully. It's body will iterate over the list of parsed
#    positional arguments and assign them to the newly created local
#    variables named by the elements of the array. If more than 
#    expected number of positional arguments was parsed, the calling
#    context may recognize it by reading length of the @var posargs
#    array. If @var arguments array is not provided (or if is not an
#    array), the parsing process will not proceed
# 
# @environment
#
#             arguments  array containing names for variables that
#                        positional arguments will be parsed into;
#                        if not given, positional arguments will
#                        be parsed only into the posargs array
#       opt_definitions  array containing options' definitions
# 
#     VERBOSE_PARSEARGS  if set non-empty, `parseargs` function will
#                        be called with a --verbose flag
#
# @provides
#
#               args  array containing all arguments passed to the
#                     calling script/function
#            posargs  array of parsed non-option arguments (if 
#                     opt_definitions defined)
#            options  hash array of parsed options (if 
#                     opt_definitions defined)
#  "${arguments[@]}"  set of variables named with values hold
#                     in the @var arguments array (if that was
#                     defined)
#
# @note As this alias calls directly `parseargs` function, all 
#    environment variables used by this function are usable to 
#    configure function's behaviour
#
# @note When parsing arguments, this alias takes an action based
#    on the existence of the non-empty @var opt_definitions
#    and @var arguments arrays. When it is used in the context of 
#    the function that uses neither options or automatic dispatch
#    of arguments it is strongly advise to still declare both of 
#    these variables localy as empty arrays. This hides possibly
#    identically named arrays declared in the context of the 
#    upstream function that uses it while also using `parse_arguments`
#    alias. In turn there is no risk of parsing process failing
#    while trying to parse options from the upper context 
#    (@see example (1))
#
# @example (1)
#
#    # -----------------------------------------------------------
#    # This example shows a way to use the alias in the context
#    # of the library function that does not use options and does
#    # not need to automatically parse positional arguments
#    # into named variables
#    # -----------------------------------------------------------
#
#    # Declare both opt_definitions and arguments to hide names from
#    # the upstream context
#    local -a opt_definitions
#    local -a arguments
#    
#    # Parse arguments safely
#    parse_arguments
#
#    # Use posargs list to get positional arguments
#    echo "Positional arguments num: ${#posargs[@]}"
#    echo "Positional arguments: ${posargs[@]}"
#
# @example (2)
#
#    # -----------------------------------------------------------
#    # This example shows a standard way to use the alias in the
#    # function context
#    # -----------------------------------------------------------
#
#    # Declare names of variables that will hold positional arguments
#    local -a arguments=(
#       positional_argument_1    
#       positional_argument_2    
#       positional_argument_3    
#    )
#
#    # Define some options
#    local -a opt_definitions=(
#       '-v|--verbose',verbose,f
#       '-s|--some-option',some,f
#       '-o|--some-other',some_other
#    )
#
#    # If needed set variables that configure behaviour of the 
#    # `parseargs` function (@see `parseargs`)
#    ...
#
#    # Parse arguments
#    parse_arguments
#
#    # Use posargs list to get positional arguments
#    echo "Positional arguments num: ${#posargs[@]}"
#    echo "Positional arguments: ${posargs[@]}"
#
#    # Use options hash table to check what options has been passed
#    is_var_set options[verbose] && 
#        log_info "Verbose option has been passed"    
#    is_var_set options[some_other] &&
#        log_info "Value of the --some-other option is ${options[some_other]}"    
#
# @example (3)
#
#    # -----------------------------------------------------------
#    # This example shows a standard way to use the alias in the
#    # script context
#    # -----------------------------------------------------------
#
#    # Set usage message
#    local USAGE=...
#
#    # Declare names of variables that will hold positional arguments
#    local -a arguments=(
#       positional_argument_1    
#       positional_argument_2    
#       positional_argument_3    
#    )
#
#    # Define some options
#    local -a opt_definitions=(
#       '-h|--help',help,f
#       '-v|--verbose',verbose,f
#       '-s|--some-option',some,f
#       '-o|--some-other',some_other
#    )
#
#    # Set VERBOSE_PARSEARGS to automatically print log to the user
#    # wither when the error occurs during parsing or when the usage
#    # essage (--help switch) has been requested
#    local VERBOSE_PARSEARGS=1
#
#    # If needed set variables that configure behaviour of the 
#    # `parseargs` function (@see `parseargs`)
#    ...
#
#    # Parse arguments
#    parse_arguments
#
#    # Use posargs list to get positional arguments
#    echo "Positional arguments num: ${#posargs[@]}"
#    echo "Positional arguments: ${posargs[@]}"
#
#    # Use options hash table to check what options has been passed
#    is_var_set options[verbose] && 
#        log_info "Verbose option has been passed"    
#    is_var_set options[some_other] &&
#        log_info "Value of the --some-other option is ${options[some_other]}" 
#
#    # Use named variables to refer expected positional arguments
#    log_info "This is the first positional argument: ${positional_argument_1}"
#
#    # Note, that if number of passed positional arguments was smaller
#    # than the expected number (i.e. length of the arguments array),
#    # some of the named values were set to an empty string!
#    if [[ ${#posargs[@]} < ${#arguments[@]} ]]; then
#         log_error "The 'positional_argument_3' argument is lacking!"
#    fi
#    
# -------------------------------------------------------------------
alias parse_arguments='
# Parse arguments to a named array
local -a args=( "$@" )

# Prepare names hash arrays for positional arguments and parsed options
local -a posargs
local -A options

# Define options passed to the `parseargs`
local -a parseargs_options=()
is_var_set_non_empty VERBOSE_PARSEARGS  && parseargs_options+=( "--verbose" )
is_var_set_non_empty opt_definitions[0] && parseargs_options+=( "--options-defs=opt_definitions" )
is_var_set_non_empty opt_definitions[0] && parseargs_options+=( "--options-dst=options" )

# Parse options
local __ret_
parseargs ${parseargs_options[@]} -- args posargs && __ret_="$?" || __ret_="$?"
# Return 0 if help requested
[[ "$__ret_" == 2 ]] && return 0 ||
# Return 1 if parsing error occurred
[[ "$__ret_" != 0 ]] && return 1

# Parse positional arguments into the named values
if is_var_set_non_empty arguments[0]; then

    local _pos_arg_idx_

    # Iterate over expected named arguments and declare them
    for _pos_arg_idx_ in "${!arguments[@]}"; do
        local "${arguments[$_pos_arg_idx_]}"="${posargs[$_pos_arg_idx_]:-}"
    done

fi
'
