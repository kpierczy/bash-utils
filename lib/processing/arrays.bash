#!/usr/bin/env bash
# ====================================================================================================================================
# @file     arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Monday, 21st February 2022 11:45:45 pm
# @project  bash-utils
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
#    @retval @c 0 if @p array contains an @p element 
#    @retval @c 1 otherwise
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
# @brief Prints array with name passed as @p arr argument. By 
#    default, elements of the array are written out one per line.
#    This behaviour can be changed by setting the elements' separator
#
# @param arr
#    name fo the array to be printed
#
# @options
#
#           -n|--name  if given, name of the array is printed
#  -s|--separator=STR  separator of the printed elements
#
# -------------------------------------------------------------------
function print_array() {

    # Arguments
    local arr_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-n|--name',name,f
        '-s|--separator',separator
    )
    
    # Parse arguments to a named array
    parse_options_s
    
    # Parse arguments
    local -n arr_="${posargs[0]}"

    # Parse elements' separator
    local separator_=$'\n'
    is_var_set options[separator] && 
        separator_="${options[separator]}"

    # ------------------------------------------------- 

    local out_=''

    # Print name of the array, if requested
    is_var_set options[name] && {
        
        # If separator was given, end name with either space or a new line, depending on it
        if is_var_set options[separator]; then
            is_substring "${options[separator]}" $'\n' &&
                out_="${posargs[0]}:\n" ||
                out_="${posargs[0]}: "
        # Else, use a newline (default) after the name
        else
            out_="${posargs[0]}:\n"
        fi
    }

    # If an array is empty, return
    (( ${#arr_[@]} > 0 )) || {

        # Print name, if requested (without additional newline)
        is_var_set options[name] && echo -e "${out_:0:-2}"

        return
    } 

    local elem_

    # Concatenate output string's elements
    for elem_ in "${arr_[@]}"; do
        out_="${out_}${elem_}${separator_}"
    done

    # Remove the last one separator
    out_="${out_%%$separator_}"

    # Print result
    echo -e "${out_}"

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
#    @retval @c 0 on success 
#    @retval @c 1 on error
# -------------------------------------------------------------------
function files_lines_to_array() {

    # Arguments
    local file_="$0"
    local -n arr_="$1"

    # ------------------------------------------------- 

    # Read file line by line array
    IFS=$'\n' read -d '' -ra arr_ < "$file_"

}

# -------------------------------------------------------------------
# @brife Finds maximal element in the array
#
# @param array
#    array to be inspacted
# -------------------------------------------------------------------
function max_elem() {

    # Parse arguments
    local -n array="$1"

    local max; ((max=0-2**32))

    # Iterate over array to find the largest one
    for elem in "${array[@]}"; do
        if (( $max < ${elem} )); then
            max=${elem}
        fi
    done

    echo $max
}

# -------------------------------------------------------------------
# @brife Finds length of the smallest in the array
#
# @param array
#    array to be inspacted
# -------------------------------------------------------------------
function min_elem() {

    # Parse arguments
    local -n array="$1"

    local min; ((min=-2**32))

    # Iterate over array to find the largest one
    for elem in "${array[@]}"; do
        if (( $min > ${elem} )); then
            min=${elem}
        fi
    done

    echo $max_elem
}

# -------------------------------------------------------------------
# @brife Finds length of the longest element in the array
#
# @param array
#    array to be inspacted
# -------------------------------------------------------------------
function max_len() {

    # Parse arguments
    local -n array="$1"

    local max=0

    # Iterate over array to find the longest one
    for elem in "${array[@]}"; do
        if (( $max < ${#elem} )); then
            max=${#elem}
        fi
    done

    echo $max
}

# -------------------------------------------------------------------
# @brife Finds length of the shortest element in the array
#
# @param array
#    array to be inspacted
# -------------------------------------------------------------------
function min_len() {

    # Parse arguments
    local -n array="$1"

    local min; ((min=2**32))

    # Iterate over array to find the longest one
    for elem in "${array[@]}"; do
        if (( $min > ${#elem} )); then
            min=${#elem}
        fi
    done

    echo $min
}

# -------------------------------------------------------------------
# @brife Finds first occurence of the element in the array
#
# @param array
#    name of the array to be inspacted
# @param element
#    element to be found
#
# @returns
#   @c 0 on success
#   @c 1 on failure
#
# @outputs Index of the found element on success
# -------------------------------------------------------------------
function find_first_starting_with() {

    # Parse arguments
    local -n array="$1"
    local element="$2"

    # Iterate list of arguments forward to find the first occurence of the element
    for ((i = 0; i <= ${#array[@]} - 1; i++)); do
        
        # Get the argument
        local array_elem="${array[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        [[ "${array_elem}" == "$element" ]] || continue

        # If element start found, output index
        echo $i

        return 0
        
    done

    # If no option found, return error
    return 1
}

# -------------------------------------------------------------------
# @brife Finds last occurence of the element in the array
#
# @param array
#    name of the array to be inspacted
# @param element
#    element to be found
#
# @returns
#   @c 0 on success
#   @c 1 on failure
#
# @outputs Index of the found element on success
# -------------------------------------------------------------------
function find_last() {

    # Parse arguments
    local -n array="$1"
    local element="$2"

    # Iterate list of arguments backward to find the last occurence of the element
    for ((i = ${#array[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local array_elem="${array[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        [[ "${array_elem}" == "$element" ]] || continue

        # If element found, output index
        echo $i

        return 0
        
    done

    # If no option found, return error
    return 1
}

# -------------------------------------------------------------------
# @brife Finds first occurence of the element in the array that 
#    starts with @P element_start
#
# @param array
#    name of the array to be inspacted
# @param element_start
#    element to be found
#
# @returns
#   @c 0 on success
#   @c 1 on failure
#
# @outputs Index of the found element on success
# -------------------------------------------------------------------
function find_first_starting_with() {

    # Parse arguments
    local -n array="$1"
    local element_start="$2"

    # Iterate list of arguments forward to find the first occurence of the element
    for ((i = 0; i <= ${#array[@]} - 1; i++)); do
        
        # Get the argument
        local array_elem="${array[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        starts_with "${array_elem}" "$element_start" || continue

        # If element start found, output index
        echo $i

        return 0
        
    done

    # If no option found, return error
    return 1
}

# -------------------------------------------------------------------
# @brife Finds last occurence of the element in the array that 
#    starts with @P element_start
#
# @param array
#    name of the array to be inspacted
# @param element_start
#    element to be found
#
# @returns
#   @c 0 on success
#   @c 1 on failure
#
# @outputs Index of the found element on success
# -------------------------------------------------------------------
function find_last_starting_with() {

    # Parse arguments
    local -n array="$1"
    local element_start="$2"

    # Iterate list of arguments backward to find the last occurence of the element
    for ((i = ${#array[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local array_elem="${array[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        starts_with "${array_elem}" "$element_start" || continue

        # If element start found, output index
        echo $i

        return 0
        
    done

    # If no option found, return error
    return 1
}

# -------------------------------------------------------------------
# @brife Finds first occurence of the element in the array that 
#    ends with @P element_start
#
# @param array
#    name of the array to be inspacted
# @param element_end
#    element to be found
#
# @returns
#   @c 0 on success
#   @c 1 on failure
#
# @outputs Index of the found element on success
# -------------------------------------------------------------------
function find_first_ending_with() {

    # Parse arguments
    local -n array="$1"
    local element_start="$2"

    # Iterate list of arguments forward to find the first occurence of the element
    for ((i = 0; i <= ${#array[@]} - 1; i++)); do
        
        # Get the argument
        local array_elem="${array[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        ends_with "${array_elem}" "$element_end" || continue

        # If element end found, output index
        echo $i

        return 0
        
    done

    # If no option found, return error
    return 1
}

# -------------------------------------------------------------------
# @brife Finds last occurence of the element in the array that 
#    ends with @P element_start
#
# @param array
#    name of the array to be inspacted
# @param element_end
#    element to be found
#
# @returns
#   @c 0 on success
#   @c 1 on failure
#
# @outputs Index of the found element on success
# -------------------------------------------------------------------
function find_last_ending_with() {

    # Parse arguments
    local -n array="$1"
    local element_start="$2"

    # Iterate list of arguments backward to find the last occurence of the element
    for ((i = ${#array[@]} - 1; i >= 0; i--)); do
        
        # Get the argument
        local array_elem="${array[$i]}"
        
        # Check if argument is an option; if not, continue scanning
        ends_with "${array_elem}" "$element_end" || continue

        # If element end found, output index
        echo $i

        return 0
        
    done

    # If no option found, return error
    return 1
}