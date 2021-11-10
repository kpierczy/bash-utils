#!/usr/bin/env bash
# ====================================================================================================================================
# @file     general.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:16:12 am
# @modified Tuesday, 9th November 2021 7:56:54 pm
# @project  BashUtils
# @brief
#    
#    Set of handy utilities used for creating helper scripts and functions
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Get path to the scripts's home
SCRIPT_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

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
