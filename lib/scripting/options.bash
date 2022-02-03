#!/usr/bin/env bash
# ====================================================================================================================================
# @file     options.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 7:55:41 pm
# @modified Sunday, 21st November 2021 2:59:23 pm
# @project  bash-utils
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
    local -n _pod_defs_="$1"
    local -n _pod_names_="$2"
    local -n _pod_flags_="$3"
    local -n _pod_getopts_="$4"
    
    # Initialize IFS word splitter
    local IFS=$IFS
    # Define local variables
    local _pod_defn_
    local _pod_opt_
    local _pod_short_=''
    local _pod_long_=''

    # Initialize 'getopts' hash array
    _pod_getopts_=( [long]='' [short]='' )
    
    # Iterate over all arguments/options definitions
    for _pod_defn_ in "${_pod_defs_[@]}"; do

        # Set world-splitting-separator to comma to extract parts of the option's definition
        IFS=','
        # Set positional arguments to the conent of @var defn (@notice auto word-splitting)
        set -- $_pod_defn_

        # Parse positional arguments
        local _pod_opt_name_="$1"
        local _pod_opt_var_="$2"
        local _pod_opt_flag_="${3:-}"

        # Reconfigure world-splitting-separator to extract short/long name of the option
        IFS='|'

        # Iterate over short/long name string (@notice auto word-splitting)
        for _pod_opt_ in ${_pod_opt_name_[@]}; do

            # Write variables name corresponding to the option's short/long name
            _pod_names_["$_pod_opt_"]="$_pod_opt_var_"

            # Append option's name to the one of getopt's strings (remove -/-- prefix)
            case "$_pod_opt_" in
                -?  ) _pod_short_+=,"${_pod_opt_#?}";;
                *   ) _pod_long_+=,"${_pod_opt_#??}";;
            esac

            # Check if option is a flag
            case "$_pod_opt_flag_" in
                # If keyword argument, append ': ' to the option's name
                '' ) case "$_pod_opt_" in
                        -?  ) _pod_short_+=: ;;
                        *   ) _pod_long_+=:  ;;
                     esac;;
                # If flag, wrie '1' to he @p flags hash array
                * ) _pod_flags_["$_pod_opt_"]=1;;
            esac
            
        done
        
    done

    # Write options' sets tot the @p getopts (remove prefix comma)
    _pod_getopts_[short]="${_pod_short_#?}"
    _pod_getopts_[long]="${_pod_long_#?}"

}

# -------------------------------------------------------------------
# @brief Check whether system uses GNU getopt (so called enhanced 
#     getopt) version of the getopt utility
# -------------------------------------------------------------------
is_enhanced_getopt() {

    local rc_

    # Check getopt version string and keep return value
    getopt -T &>/dev/null && rc_=$? || rc_=$?
    # Return result of the comparison to the enchanced getopt's code
    (( $rc_ == 4 ))
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
    local -n _wg_args_="$1"
    local _wg_short_="$2"
    local _wg_long_="$3"

    # Declare local variables
    local _wg_result_
    local _wg_ret_
    # Parse 
    _wg_result_=$(getopt -o "$_wg_short_" ${_wg_long_:+-l} $_wg_long_ -n $0 -- "${_wg_args_[@]}") && 
        _wg_ret_=$? || _wg_ret_=$?
    # Print result of the getopt
    echo "$_wg_result_"
    
    return $_wg_ret_
    
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
    local -n _po_args_="${1:-}"
    local -n _po_defs_="${2:-}"
    local -n _po_opts_="${3:-}"
    local -n _po_posargs_="${4:-}"
    
    # Initialize output arrays
    local -A _po_flags_
    local -A _po_getopts_
    local -A _po_names_

    # Reset error
    _err_=0

    # Parse @p defs to the form taken by getopt utility
    parse_option_defs _po_defs_ _po_names_ _po_flags_ _po_getopts_
    
    # Call getopt
    local _po_result_
    if is_enhanced_getopt; then
         _po_result_=$(wrap_getopt _po_args_ "${_po_getopts_[short]}" "${_po_getopts_[long]}") || return 1
    fi
    
    # Set positional arguments
    eval "set -- $_po_result_"
    
    # Iterate over @p args_ as long as an option is seen
    while [[ "${1:-}" == -?* ]]; do
        
        # If '--' met, break
        [[ "$1" == -- ]] && {
            shift
            break
        }
        # If the option passed but not defined, return error
        is_var_set _po_names_["$1"] || {
            _err_=1
            return
        }
        # Else, parse value of the option
        ! is_var_set _po_flags_["$1"]
        case $? in
            # Parse keyword option
            0 ) _po_opts_["${_po_names_["$1"]}"]="$2"
                shift
                ;;
            # Parse flag option
            * ) _po_opts_["${_po_names_["$1"]}"]=1;;
        esac
        # Shift to the next arg
        shift

    done
    
    # Set positional arguments to remaining args
    _po_posargs_=( "$@" )

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

    # Iterate list of arguments backward to find the last occurence of the option
    for ((i = ${#args_[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local single_arg_="${args_[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        starts_with "${single_arg_}" "-" || continue

        # Check if long option found
        if starts_with "${single_arg_}" "--"; then
            
            # If so, remove potential vale of the option trailing everything beyond '='
            single_arg_="${single_arg_%=*}"

        # Else, if short option found
        else
            
            # Extract an option from the string trayling everything beyond the dash and the first letter
            single_arg_="${single_arg_:0:2}"

        fi

        local opt_name_

        # Iterate over names of the searched option
        for opt_name_ in "${_names_list_}"; do

            # If name matches one of the names of the searched option, exit function as success
            [[ "$opt_name_" == "$single_arg_" ]] && {
                echo "$opt_name_"
                return 0
            }

        done

    done

    # If no option found, return error
    return 1

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
#       args  list containing arguments of the calling 
#             script/function
#    posargs  array of parsed non-option arguments
#    options  hash array of parsed options
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
