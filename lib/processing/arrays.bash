#!/usr/bin/env bash
# ====================================================================================================================================
# @file     arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Friday, 12th November 2021 12:06:59 am
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
# @brief Sums elements of two arrays and palces the result in 
#    @p result array (first + second = result)
# 
# @param first
#    first array to be summed
# @param second
#    second array to be summed
# @param result
#    result array
# -------------------------------------------------------------------
function sum_arrays() {

    # Arguments
    local -n first_="$1"
    local -n second_="$2"
    local -n result_="$3"

    # Local variables
    local -a out_array_

    # Sum arrays
    out_array_+=( "${first_[@]}" )
    out_array_+=( "${second_[@]}" )

    # Set result
    result_=( "${out_array_[@]}" )

}

# -------------------------------------------------------------------
# @brief Substracts elements from the @p second array from the 
#    elements of the @p first array and palces the result in 
#    @p result array (first - second = result)
# 
# @param first
#    first array to be summed
# @param second
#    second array to be summed
# @param result
#    result array
#
# @note Any element from the @p first array that is present also
#    in the @p second array is removed from the result 
# @note This implementation is slow
# -------------------------------------------------------------------
function substract_arrays() {

    # Arguments
    local -n first_="$1"
    local -n second_="$2"
    local -n result_="$3"

    # Local variables
    local -a out_array_

    # Iterate over the first array
    for i in "${!first_[@]}"; do
    
        # If first array's element is also an element of the second array, continue
        is_array_element second_ "${first_[$i]}" && continue
        # Else, add element to the result array
        out_array_+=("${first_[$i]}")
        
    done

    # Set result
    result_=( "${out_array_[@]}" )

}

# -------------------------------------------------------------------
# @brief Prints array with name passed as @p arr argument
#
# @param arr
#    name fo the array to be printed
#
# @options
#
#    -n  if given, name of the array is printed
#
# -------------------------------------------------------------------
function print_array() {

    # Arguments
    local -n arr

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-n',name,f
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    arr="${posargs[0]}"

    # ------------------------------------------------- 

    # Print name of the array
    is_var_set options[name] && echo "${posargs[0]}:"

    # Print array
    for elem in "${arr[@]}"; do
        echo "$elem"
    done

}

# -------------------------------------------------------------------
# @brief Fills @p array with the lines of the @p file
#
# @param file
#    name fo the source file
# @param arr
#    name fo the destination array
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error
# -------------------------------------------------------------------
function files_lines_to_array() {

    # Arguments
    local file_="$0"
    local -n arr_="$1"

    # ------------------------------------------------- 

    # Read file line by line array
    IFS=$'\n' read -d '' -ra arr_ < "$file_"

}