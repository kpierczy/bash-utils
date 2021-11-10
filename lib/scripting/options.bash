#!/usr/bin/env bash
# ====================================================================================================================================
# @file     options.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 7:55:41 pm
# @modified Wednesday, 10th November 2021 7:41:38 pm
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
    is_enhanced_getopt && result=$(wrap_getopt args_ "${getopts_[short]}" "${getopts_[long]}")
    [[ $? == "0" ]] || return 1

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
parseopts args opt_definitions options posargs || return 1
'

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
