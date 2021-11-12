#!/usr/bin/env bash
# ====================================================================================================================================
# @file     options.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 7:55:41 pm
# @modified Friday, 12th November 2021 8:02:31 pm
# @project  BashUtils
# @brief
#    
#    Set of tools related to options' parsing
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Prepares @p names and @p flags hash arrays holding pairs
#    <cmd-line-option_name, x> where 'x' is script-space name of the
#    key holding value of the parsed option and '1' if option is a 
#    flag accordingly
#
# @param defs
#    name of the array holding definitions of the options 
#    (@see parseopts)
# @param names (out)
#    output associative array holding pairs option_name/option_value
# @param flags (out)
#    output associative array holding values (1) corresponding to
#    parsed flag options
# @param getopts (out)
#    output associative array holding two pairs - <short,...> and
#    <long,...> containing strings with comma-separated lists of 
#    names of short and long options defined in @p defs
# -------------------------------------------------------------------
function parse_option_defs () {

    # Arguments
    local -n _defs_=$1
    local -n _names_=$2
    local -n _flags_=$3
    local -n _getopts_=$4
    
    # Initialize IFS word splitter
    local IFS=$IFS
    # Define local variables
    local _defn_
    local _opt_
    local _short_=''
    local _long_=''

    # Initialize 'getopts' hash array
    _getopts_=( [long]='' [short]='' )
    
    # Iterate over all arguments/options definitions
    for _defn_ in "${_defs_[@]}"; do

        # Set world-splitting-separator to comma to extract parts of the option's definition
        IFS=','
        # Set positional arguments to the conent of @var defn (@notice auto word-splitting)
        set -- $_defn_

        # Parse positional arguments
        local _opt_name_="$1"
        local _opt_var_="$2"
        local _opt_flag_="${3:-}"

        # Reconfigure world-splitting-separator to extract short/long name of the option
        IFS='|'

        # Iterate over short/long name string (@notice auto word-splitting)
        for _opt_ in ${_opt_name_[@]}; do

            # Write variables name corresponding to the option's short/long name
            _names_["$_opt_"]="$_opt_var_"

            # Append option's name to the one of getopt's strings (remove -/-- prefix)
            case "$_opt_" in
                -?  ) _short_+=,"${_opt_#?}";;
                *   ) _long_+=,"${_opt_#??}";;
            esac

            # Check if option is a flag
            case "$_opt_flag_" in
                # If keyword argument, append ': ' to the option's name
                '' ) case "$_opt_" in
                        -?  ) _short_+=: ;;
                        *   ) _long_+=:  ;;
                     esac;;
                # If flag, wrie '1' to he @p flags hash array
                * ) _flags_["$_opt_"]=1;;
            esac
            
        done
        
    done

    # Write options' sets tot the @p getopts (remove prefix comma)
    _getopts_[short]="${_short_#?}"
    _getopts_[long]="${_long_#?}"

}

# -------------------------------------------------------------------
# @brief Check whether system uses GNU getopt (so called enhanced 
#     getopt) version of the getopt utility
# -------------------------------------------------------------------
is_enhanced_getopt() {
    # Check getopt version string and keep return value
    getopt -T &>/dev/null && rc=$? || rc=$?
    # Return result of the comparison to the enchanced getopt's code
    (( $rc == 4 ))
}

# -------------------------------------------------------------------
# @brief Wrapper aroung 'getop' glueing utilities' interface with
#    getop's interface
#
# @param args
#    arguments co be parsed
# @param short
#    string representing comma-separated list of short options
#    to be parsed (it it created from @p def argument by the 
#    @f parse_option_defs function)
# @param long
#    string representing comma-separated list of long options
#    to be parsed (it it created from @p def argument by the 
#    @f parse_option_defs function)
#
# @stdout
#    prints an expression to be evaluetd by the calling context 
#    depending on the result of the getopt command
# -------------------------------------------------------------------
function wrap_getopt () {
    
    # Arguments
    local -n _args_="$1"
    local _short_="$2"
    local _long_="$3"

    # Declare local variables
    local _result_
    local _ret_
    # Parse 
    _result_=$(getopt -o "$_short_" ${_long_:+-l} $_long_ -n $0 -- "${_args_[@]}") && _ret_=$? || _ret_=$?
    # Print result of the getopt
    echo "$_result_"
    
    return $_ret_
    
}

# -------------------------------------------------------------------
# @brief Iterates over @p args and parses command-line options
#    according to the scheme described in @p defs. 
# 
# @param args 
#    name of the array containing arguments to be parsed
# @param defs
#    name of the array holding options to be parsed in shape 
# 
#     defs=(
#         '-o|option1',o_flag,f # Flag options
#         '-s|option2',s_var    # Keyword options
#     )
#
#     Format of the single record in the @p defs array is as 
#     follows: opt_name, var_name, [f]. 'opt_name' is string
#     describing command-line shape of the option. Using '|'
#     one can define both short and long name. 'var_name' is name
#     of the record that the value of the option will be written
#     under in the @p opts hash array (if parsed). Optional 'f'
#     flag marks that the option is a flag (valued in the @p opts
#     array with '1', if parsed)
#
# @param opts (out)
#    name of the hash array that options has to be parsed into
# @param posargs (out)
#    name of the array that positional arguments has to be parsed
#    into
#
# @glob _err_
#    sets @var _err_ variable to indicate return status. If @c 1,
#    an unknown option (i.e. one not defined by @p defs) has been
#    parsed
#
# @exaple
#
#    # Declare descriptor of the options taken by the script/function
#    declare -a defs=(
#        -o,o_flag,f
#        -c,c_flag,f
#        '-d|--def',def_var
#    )
#
#    # Parse options
#    local -A options
#    # @note Wor-spliiting needs to be enabled!
#    enable_word_splitting
#    parseopts "$*" defs options posargs
#
#    # Use 'options' and 'posargs' to examine parsed options
#    print_hash_array options
#    print_array posargs
# -------------------------------------------------------------------
function parseopts () {
    
    # Arguments
    local -n args_="$1"
    local -n defs_="$2"
    local -n opts_="$3"
    local -n posargs_="$4"
    
    # Initialize output arrays
    local -A flags_
    local -A getopts_
    local -A names_

    # Reset error
    _err_=0

    # Parse @p defs to the form taken by getopt utility
    parse_option_defs defs_ names_ flags_ getopts_

    # Call getopt
    local result
    if is_enhanced_getopt; then
         result=$(wrap_getopt args_ "${getopts_[short]}" "${getopts_[long]}") || return 1
    fi

    # Set positional arguments
    eval "set -- $result"

    # Iterate over @p args_ as long as an option is seen
    while [[ "${1:-}" == -?* ]]; do
        
        # If '--' met, break
        [[ "$1" == -- ]] && {
            shift
            break
        }
        # If the option passed but not defined, return error
        is_var_set names_["$1"] || {
            _err_=1
            return
        }
        # Else, parse value of the option
        ! is_var_set flags_["$1"]
        case $? in
            # Parse keyword option
            0 ) opts_["${names_["$1"]}"]="$2"
                shift
                ;;
            # Parse flag option
            * ) opts_["${names_["$1"]}"]=1;;
        esac
        # Shift to the next arg
        shift

    done
    
    # Set positional arguments to remaining args
    posargs_=( "$@" )
    
}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a short option (in sense
#    of the `getopt` tool, i.e. if it is a letter with a single
#    leading dash)
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is a short option \n
#    @c 1 otheriwse
# -------------------------------------------------------------------
function is_short_option() {

    # Arguments
    local string_="$1"

    # Check if a short option
    [[ ${#string_} == "2" ]] &&
    [[ ${string_:0:1} == "-" ]] &&
    [[ ${string_:1:1} =~ [[:alpha:]] ]] ||
    # If not, return error
    return 1

    # If a valid short option, return success
    return 0

}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a long option (in sense
#    of the `getopt` tool, i.e. if it is a non-empty string with 
#    a double leading dash)
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is a long option \n
#    @c 1 otheriwse
# -------------------------------------------------------------------
function is_long_option() {

    # Arguments
    local string_="$1"

    # Check if a long option
    starts_with "$string_ " "--" && 
    (( $(strlen "${string_:2}") != 0 )) &&
    is_identifier --extend--charset='-' "${string_:2}" ||
    # If not, return error
    return 1

    # If a valid long option, return success
    return 0

}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a short or a long option
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is an option \n
#    @c 1 otheriwse
#
# @see is_short_option
# @see is_long_option
# -------------------------------------------------------------------
function is_option() {

    # Arguments
    local string_="$1"

    # Check if an option
    is_short_option string_ || is_long_option string_

}

# -------------------------------------------------------------------
# @brief Based on the list of arguments and options' definitions
#    finds name of the option corresponding to the name of the
#    key in the @p options hash table returned by the @fun parseopts
#    function. Nameis written to the stdout
#
# @params args
#    list of arguments to be parsed
# @params defs
#    list of valid options' definitions
# @param key
#    name of the key to be matched
#
# @returns 
#    @c 0 on success \n
#    @c 1 either if the option corresponding to the @p key
#       was not declared in the @p defs list or it does not
#       appear on the @p args list
#
# @note Function returns name of the the last occurrence of the 
#    option in the @p args list
# -------------------------------------------------------------------
function get_option_name() {

    # Arguments
    local -n args_="$1"
    local -n defs_="$2"
    local -n key_="$3"

    # Local iterator
    local _def_
    # Name of the option
    local _name_
    local _flag_

    # Search a list of definitions to find name(s) corresponding to the given key
    for _def_ in "${defs_[@]}"; do

        # Set world-splitting separator to comma to extract parts of the option's definition
        localize_word_splitting
        push_stack "$IFS"
        IFS=','
        # Set positional arguments to the conent of @var defn (@notice auto word-splitting)
        set -- $_def_
        # Restor the prevous word-splitting separator
        pop_stack IFS

        # Parse positional arguments
        local _def_name_="$1"
        local _def_key_="$2"
        local _def_flag_="${3:-}"

        # Check if the key matches
        if [[ "$key_" == "$_def_key_" ]]; then

            # If so, get it's name and type (flag/non-flag)
            _name_="$_def_name_"
            _flag_="$_def_flag_"
            # And break the loop
            break

        fi

    done

    # If name was not found on the list of definitions, return error
    is_var_set_non_empty _name_ || return 1

    # Set world-splitting separator to comma to extract option's names
    localize_word_splitting
    push_stack "$IFS"
    IFS='|'
    # Set positional arguments to the conent of @var defn (@notice auto word-splitting)
    set -- $_name_
    # Restor the prevous word-splitting separator
    pop_stack IFS
    # Get list of names fro positional arguments
    local -a _names_list_=( "$@" )

    # Name of the options found in the arguments' list
    local _name_found_

    # Iterate list of arguments backward to find the last occurence of the option
    for ((i = ${#args_[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local single_arg_="${args_[$i]}"
        
        # @todo


    done


}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Common idiom for parsing arguments of the function taking
#    some options. Based on the @var opt_definitions array current
#    positional arguments are parsed to the @var options hash array.
#    Non-option arguments are gathered to the @var posargs array 
#    that in turn is set as a new source of the positional arguments
#    
#    If @f parseopts returns an error alias will call 'return 1' in
#    the calling context
# 
# @environment
#
#       opt_definitions  array containing options' definition 
#
# @provides
#
#    options  hash array of parsed options
#    posargs  array of parsed non-option arguments
#
# -------------------------------------------------------------------
alias parse_options='
# Parse arguments to a named array
local -a args=( "$@" )

# Prepare names hash arrays for positional arguments and parsed options
local -a posargs
local -A options

# Parse options
parseopts args opt_definitions options posargs || return 1
'

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Parses and verifies command-line options passed to the 
#    script performs routines common to many scripts:
#
#         - Prints error logs to the stdout if invalid
#           options passed
#         - Prints usage message, if the `--help` option
#           parsed
#         - Verifies whether required number of positional
#           arguments has been passed
#
# @param args 
#    name of the array containing arguments to be parsed
# @param defs
#    name of the array holding options to be parsed in shape 
# 
#     defs=(
#         '-o|option1',o_flag,f # Flag options
#         '-s|option2',s_var    # Keyword options
#     )
#
#     Format of the single record in the @p defs array is as 
#     follows: opt_name, var_name, [f]. 'opt_name' is string
#     describing command-line shape of the option. Using '|'
#     one can define both short and long name. 'var_name' is name
#     of the record that the value of the option will be written
#     under in the @p opts hash array (if parsed). Optional 'f'
#     flag marks that the option is a flag (valued in the @p opts
#     array with '1', if parsed)
#
# @param options (out)
#    name of the hash array that options has to be parsed into
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
#       ARGn_MIN  If set, a minimal value of the x option (where 
#                 x is a name of the key in the @p options hash
#                 array where the option is parsed into)
#       ARGn_MAX  If set, a maximal value of the x option (where 
#                 x is a name of the key in the @p options hash
#                 array where the option is parsed into)
#
#    LOG_CONTEXT  contex of the printed logs
#
# -------------------------------------------------------------------
function script_parseopts() {

    # Arguments
    local -n args_="$1"
    local -n defs_="$2"
    local -n options_="$3"
    local -n posargs_="$4"

    # Parse options
    parseopts args_ defs_ options_ posargs_ || {
        log_error "Invalid usage"
        is_var_set_non_empty USAGE && log_error "$USAGE"
        return 1
    }

    # Display usage, if requested
    is_var_set options[help] && {
        is_var_set_non_empty USAGE && log_error "$USAGE"
        return 0
    }

    # ---------- Verify positional arguments ----------

    # Check if required number of arguments was given
    if is_var_set_non_empty ARG_NUM; then

        (( ${#posargs_[@]} == $ARG_NUM )) || {
            log_error "Wrong number of arguments"
            is_var_set_non_empty USAGE && echo "$USAGE"
            return 1
        }

    # Check if number of arguments lies in the valid range
    else

        # Chekc if minimal number of arguments has been given
        is_var_set_non_empty ARG_NUM_MIN && (( ${#posargs_[@]} >= $ARG_NUM_MIN )) || {
            log_error "Too fiew arguments"
            is_var_set_non_empty USAGE && echo "$USAGE"
            return 1
        }

        # Chekc if maximal number of arguments has been given
        is_var_set_non_empty ARG_NUM_MAX && (( ${#posargs_[@]} <= $ARG_NUM_MAX )) || {
            log_error "Too many arguments"
            is_var_set_non_empty USAGE && echo "$USAGE"
            return 1
        }

    fi

    local arg_num_
    local arg_num_conjugated_
    local i
    
    # Validate positional arguments
    for i in "${!posargs_[@]}"; do

        # Get index of the argument
        arg_num_=$(( i + 1 ))

        # Conjugation argument's number
        arg_num_conjugated_=$(inflect_numeral $arg_num_)

        # If an argument is allowed to have only a predefined values
        if is_var_set_non_empty ARG${arg_num_}_VARIANTS; then
        
            # Check if argument has an anticipated value
            is_array_element ARG${arg_num_}_VARIANTS "${posargs_[$i]}" || {

                log_error \
                    "Invalid value of the $arg_num_conjugated_ argument (${posargs_[$i]})" \
                    "Valid values are: [ $(print_array ARG${arg_num_}_VARIANTS -s ', ') ]"
                    
                is_var_set_non_empty USAGE && echo "$USAGE"
                return 1
            }

        # Else, check if argument is in a predefined range
        else 

            # Check if argument's value is not lesser than a minimal one
            is_var_set_non_empty ARG${arg_num_}_MIN &&
            [[ "${posargs_[$i]}" -ge "ARG${arg_num_}_MIN" ]] || {

                log_error \
                    "$arg_num_conjugated_ too small (${posargs_[$i]})" \
                    "Minimal value is (ARG${arg_num_}_MIN)"
                    
                is_var_set_non_empty USAGE && echo "$USAGE"
                return 1
            }

            # Check if argument's value is not greater than a maximal one
            is_var_set_non_empty ARG${arg_num_}_MAX &&
            [[ "${posargs_[$i]}" -ge "ARG${arg_num_}_MAX" ]] || {

                log_error \
                    "$arg_num_conjugated_ too large (${posargs_[$i]})" \
                    "Minimal value is (ARG${arg_num_}_MAX)"
                    
                is_var_set_non_empty USAGE && echo "$USAGE"
                return 1
            }
        fi

    done

    # ----------- Verify optional arguments -----------

    local opt_

    # Validate optional arguments
    for opt_ in "${!options_[@]}"; do

        # @todo
        
        # If an option is allowed to have only a predefined values
        if is_var_set_non_empty ${opt_}_VARIANTS; then
        
        # Else, check if an option is in a predefined range
        else     
            
        fi

    done

}

# -------------------------------------------------------------------
# @brief Common idiom for parsing script's cmd-line arguments with
#    the user-visible log. Alias provides a hash array @a options
#    containing set of parsed options. It also sets positional 
#    arguments of the script to @a posargs array returned by 
#    @fun parseopts function
#
# @environment
#
#  opt_definitions  array containing options' definition 
#            usage  usage heredoc string
#          ARG_NUM  number of required positional arguments (not verified
#                   if undefined)
#
# @provides
#
#    options  hash array of parsed options
#
# -------------------------------------------------------------------
alias parse_script_options='
# Disable word-splitting to parse positional arguments in a proper way
push_stack "$IFS"
disable_word_splitting

# Parse arguments to a named array
local -a args=( "$@" )

# Restore previous mode of the word-splitting
pop_stack IFS

# Prepare names hash arrays for positional arguments and parsed options
local -a posargs
local -A options

# Parse options
parseopts args opt_definitions options posargs || {
    log_error "Invalid usage"
    echo $usage
    return 1
}

# Display usage, if requested
is_var_set options[help] && {
    echo $usage
    return 0
}

# Set positional arguments (except cmd)
set -- ${posargs[@]}

# Verify number of given arguments
is_var_set_non_empty ARG_NUM && (( $# >= $ARG_NUM )) || {
    log_error "Too few arguments"
    echo $usage
    return 1
}
'

# -------------------------------------------------------------------
# @brief Common idiom for parsing script's cmd-line arguments for
#    multi-commands scripts.
#
#    Alias provides a hash array @a options containing set of 
#    parsed options. It also sets positional arguments of the script
#    to @a posargs array returned by @fun parseopts function ($1 is set
#    to the first positional argument after the command's name)
#
# @environment
#
#  opt_definitions  array containing options' definition 
#            usage  usage heredoc string
#         COMMANDS  list of command provided by the script
#     "$CMD"_usage  usage heredoc string(s) for script's CMD command; if no
#                   CMD_usage variable exists for the parse command, the
#                   default 'usage' is assummed
#   $"CMD"_ARG_NUM  number of required positional arguments required by
#                   CMD command (not verified if undefined)
#
# @provides
#
#        cmd  name of the command requested on command line
#    options  hash array of parsed options
#
# @note Alias replaces all "-" in the name of parsed commands to "_"
#    and so elements of the COMMANDS array has to be in the same 
#    format
# -------------------------------------------------------------------
alias parse_script_options_multicmd='
# Disable word-splitting to parse positional arguments in a proper way
push_stack "$IFS"
disable_word_splitting

# Parse arguments to a named array
local -a args=( "$@" )

# Restore previous mode of the word-splitting
pop_stack IFS

# Prepare names hash arrays for positional arguments and parsed options
local -a posargs
local -A options

# Parse options
parseopts args opt_definitions options posargs || {
    log_error "Invalid usage"
    echo $usage
    return 1
}

# Parse command
local cmd=${1:-}

# Change all "-" to "_" in the name of the command 
cmd=${cmd//-/_}

# Get name of the variable holding the usage string of the command
local cmd_usage=usage; [[ "$cmd"_usage != _usage ]] && cmd_usage="$cmd"_usage

# Check if a valid command given
is_array_element COMMANDS $cmd || is_var_set options[help] || {
    log_error "Invalid command given ($cmd)"
    echo $usage
    return 1
}

# Display usage, if requested
is_var_set options[help] && {
    is_var_set_non_empty cmd && echo $usage || echo ${!cmd_usage}
    return 0
}

# Set positional arguments
set -- ${posargs[@]:1}

# Set number of arguments required by the command
local CMD_ARG_NUM_REF="$cmd"_ARG_NUM

# Verify number of given arguments
! is_var_set_non_empty $CMD_ARG_NUM_REF || (( $# >= ${!CMD_ARG_NUM_REF} )) || {
    echo $CMD_ARG_NUM_REF
    log_error "Too few arguments"
    echo ${!cmd_usage}
    return 1
}
'
