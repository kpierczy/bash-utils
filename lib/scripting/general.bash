#!/usr/bin/env bash
# ====================================================================================================================================
# @file     general.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:16:12 am
# @modified Saturday, 6th November 2021 5:37:24 pm
# @project  BashUtils
# @brief
#    
#    Set of handy utilities used for creating helper scripts and functions
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================


# Get path to the scripts's home
SCRIPT_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# Source hlper utilities
source $SCRIPT_HOME/variables.bash

# =========================================================== Definitions ========================================================== #

# -------------------------------------------------------------------
# @brief A helper alias used to check content of the @var _err_ and
#    conditionally exit it's value when the error (non-zero value)
#    was set. This alias can by used if the functions called report
#    their failure with the global @var _err_ instead of the return
#    value.
# -------------------------------------------------------------------
alias noerror?='! (( ${_err_:-} )) || (exit $_err_)'

# -------------------------------------------------------------------
# @brief Helper alias used to parse keyword arguments passed to the
#    function
#
# @example
#
#    foo() {
#       
#       # Parse requried arguments
#       local req_arg_1=$1; shift
#       local req_arg_2=$2; shift
#       # Set default values for keyword arguments
#       local kwarg1=def_val_1
#       local kwarg2=def_val_2
#       # Parse keyword arguments
#       kwargs $@ 
#
#       [...]
#    }
#
#    foo req1 req2 kwarg1=val1 kwarg2=val2
#   
# -------------------------------------------------------------------
alias kwargs='(( $# )) && local'

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
denormopts () {

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
        # Set positional arguments to the conent of @var defn
        set -- $_defn_

        # Parse positional arguments
        local _opt_name_=$1
        local _opt_var_=$2
        local _opt_flag_=${3:-}

        # Reconfigure world-splitting-separator to extract short/long name of the option
        IFS='|'

        # Iterate over short/long name string
        for _opt_ in ${_opt_name_[@]}; do

            # Write variables name corresponding to the option's short/long name
            _names_[$_opt_]=$_opt_var_

            # Append option's name to the one of getopt's strings (remove -/-- prefix)
            case $_opt_ in
                -?  ) _short_+=,${_opt_#?};;
                *   ) _long_+=,${_opt_#??};;
            esac

            # Check if option is a flag
            case $_opt_flag_ in
                # If keyword argument, append ': ' to the option's name
                '' ) 
                case $_opt_ in
                    -?  ) _short_+=: ;;
                    *   ) _long_+=:  ;;
                esac
                ;;
                # If flag, wrie '1' to he @p flags hash array
                * ) _flags_[$_opt_]=1;;
            esac
            
        done
        
    done

    # Write options' sets tot the @p getopts (remove prefix comma)
    _getopts_[short]=${_short_#?}
    _getopts_[long]=${_long_#?}

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
#    @f denormopts function)
# @param long
#    string representing comma-separated list of long options
#    to be parsed (it it created from @p def argument by the 
#    @f denormopts function)
#
# @stdout
#    prints an expression to be evaluetd by the calling context 
#    depending on the result of the getopt command
# -------------------------------------------------------------------
wrap_getopt () {
    
    # Arguments
    local args="$1"
    local short=$2
    local long=$3

    # Declare local variables
    local result
    # Parse 
    ! result=$(getopt -o "$short" ${long:+-l} $long -n $0 -- $args)
    # Depending on the getopt's result, return expression to be evaluated
    case $? in
        0 ) echo "$result"; return 1;;
        * ) echo "$result"; return 0;;
    esac
}

# -------------------------------------------------------------------
# @brief Iterates over @p args and parses command-line options
#    according to the scheme described in @p defs. 
# 
# @param args 
#    arguments to be parsed
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
parseopts () {
    
    # Arguments
    local args_="$1"
    local -n defs_=$2
    local -n opts_=$3
    local -n posargs_=$4
    
    # Initialize output arrays
    local -A flags_
    local -A getopts_
    local -A names_

    # Reset error
    _err_=0

    # Parse @p defs to the form taken by getopt utility
    denormopts defs_ names_ flags_ getopts_

    # Set content of @p args as new positional argumets
    set -- $args_

    # Call getopt
    local result
    is_enhanced_getopt && result=$(wrap_getopt "$*" "${getopts_[short]}" "${getopts_[long]}")
    [[ $? == "0" ]] || return 1

    # Set positional arguments
    eval "set -- $result"

    # Iterate over @p args_ as long as an option is seen
    while [[ ${1:-} == -?* ]]; do
        
        # If '--' met, break
        [[ $1 == -- ]] && {
            shift
            break
        }
        # If the option passed but not defined, return error
        is_var_set names_[$1] || {
            _err_=1
            return
        }
        # Else, parse value of the option
        ! is_var_set flags_[$1]
        case $? in
            # Parse keyword option
            0 ) opts_[${names_[$1]}]=$2
                shift
                ;;
            # Parse flag option
            * ) opts_["${names_[$1]}"]=1;;
        esac
        # Shift to the next arg
        shift

    done
    # Set positional arguments to remaining args
    posargs_=( $@ )
    
}

# -------------------------------------------------------------------
# @brief Reads heredoc text from the standard input into the 
#    variable named with the @p var argument's value. Heredoc
#    is read with delimiter set to NULL so that multi-line input
#    can be read. Also the 'r' option of the 'read' command is
#    set to not interprete escape sequences
#
#    Trails leading and clocing newline characters but leaves
#    white characters.
# 
# @param var (out)
#    name of the variable that the heredoc will be read into    
# 
# @see https://wiki.bash-hackers.org/syntax/redirection#here_documents
# -------------------------------------------------------------------
get_multiline_heredoc () {

    # Arguments
    declare -n var=$1

    # Read the stdin (leading negation is used to prevent 'errexit')
    ! IFS=$'\n' read -rd '' var
}

# -------------------------------------------------------------------
# @brief Reads heredoc from the stdin using @f get_multiline_heredoc()
#    and trimms indentation white characters from all line of the 
#    doc. Puts result into the variable named by the value of the
#    @p heredoc variable
# 
# @param heredoc (out)
#    name of the variable that the read heredoc will be read into
# @see get_multiline_heredoc()
# -------------------------------------------------------------------
get_heredoc () {
    
    # Arguments
    local -n heredoc_=$1
    
    # Local variables
    local indent_

    # Read multiline heredoc to the output variable
    get_multiline_heredoc heredoc_

    # Get indentation by trimming the largest suffix which start with a non-white character
    indent_=${heredoc_%%[^[:space:]]*}
    # Remove indentation prefix from the heredoc in the first line
    heredoc_=${heredoc_#$indent_}
    # Remove indentation prefix from the heredoc in other lines
    heredoc_=${heredoc_//$'\n'$indent_/$'\n'}
    
}

# -------------------------------------------------------------------
# @brief Read heredoc from the stdin using @f get_heredoc() and 
#    prints result to the stdout
#
# @see get_heredoc()
# -------------------------------------------------------------------
print_heredoc() {

    local doc

    # Read heredoc
    get_heredoc doc
    # Print result
    echo "$doc"
}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Common idiom for parsing script's cmd-line arguments. 
#    Alias provides a hash array @a options containing set of 
#    parsed options. It also sets positional arguments of the script
#    to @a posargs array returned by @fun parseopts function
#
# @environment
#
#       defs  array containing options' definition 
#      usage  usage heredoc string
#    ARG_NUM  number of required positional arguments (not verified
#             if undefined)
#
# @declared_variabled
#
#    options  hash array of parsed options
#
# -------------------------------------------------------------------
alias parse_argumants='
# Parsed options
declare -A options

# Parse options
enable_word_splitting
parseopts "$*" defs options posargs || {
    disable_word_splitting
    logc_error "Invalid usage"
    echo $usage
    return 1
}
disable_word_splitting

# Display usage, if requested
is_var_set options[help] && {
    echo $usage
    return 0
}

# Set positional arguments
set -- ${posargs[@]}

# Verify number of given arguments
is_var_set_non_empty ARG_NUM && (( $# >= $ARG_NUM )) || {
    logc_error "Too few arguments"
    echo $usage
    return 1
}
'

# -------------------------------------------------------------------
# @brief Checks if required number of arguments was given to the 
#    script and exits when not
#
# @environment
#
#    ARG_NUM required number of arguments
# -------------------------------------------------------------------
alias check_args_num='
is_var_set_non_empty ARG_NUM && [[ "$#" = "$ARG_NUM" ]] || {
    echo $usage
    return 1
}
'
