#!/usr/bin/env bash
# ====================================================================================================================================
# @file     arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Tuesday, 9th November 2021 5:58:08 pm
# @project  BashUtils
# @brief
#    
#    Set of tools related to bash array
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================== Notes ============================================================= #

# -------------------------------------------------------------------
# From `bash man` (Special Parameters)
# ====================================
# Special Parameters
#   The shell treats several parameters specially.   These  
#   parameters  may only be referenced; assignment to them is not 
#   allowed.
#   *  Expands  to  the positional parameters, starting from one.  
#      When the expansion occurs within double quotes, it expands 
#      to a  single word with the value of each parameter separated 
#      by the first character of the IFS special variable. That is,
#      "$*" is equiva‐lent to "$1c$2c...", where c is the first 
#      character of the value of the IFS variable. If IFS is unset, 
#      the parameters are  separated by spaces. If  IFS  is null, 
#      the parameters are joined without intervening separators.
#   @  Expands to the positional parameters, starting from  one.
#      When the  expansion  occurs  within  double  quotes,  each
#      parameter expands to a separate word.  That is, "$@" is 
#      equivalent to "$1" "$2"  ...   If the double-quoted expansion 
#      occurs within a word, the expansion of the first parameter is
#      joined with  the  beginning  part  of  the original word, and 
#      the expansion of the last parameter is joined with the last 
#      part  of  the  original  word. When  there  are no positional 
#      parameters, "$@" and $@ expand to nothing (i.e., they are 
#      removed).
# -------------------------------------------------------------------

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Checks whether @p array contains an @p element
# 
# @param array
#    name of the array to be checked
# @param element
#    element to be checked
#
# @returns 
#    @c 0 if @p array contains an @p element \n
#    @c 1 otherwise
# -------------------------------------------------------------------
function is_array_element() {

    # Arguments
    local -n array_="$1"
    local element_="$2"
    # Local variables
    local e_

    # Check array
    for e_ in "${array_[@]}"; do
        [[ "$e_" == "$element_" ]] && return 0
    done

    return 1

}

# -------------------------------------------------------------------
# @brief Prints array with name passed as @p arr argument
#
# @param arr
#    name fo the array to be printed
# -------------------------------------------------------------------
print_array() {

    # Arguments
    local -n arr=$1

    # Print array
    for elem in ${arr[@]}; do
        echo "$elem"
    done

}
