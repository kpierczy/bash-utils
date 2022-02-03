#!/usr/bin/env bash
# ====================================================================================================================================
# @file     sets.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 5:56:11 pm
# @modified Wednesday, 10th November 2021 6:18:22 pm
# @project  bash-utils
# @brief
#    
#    Set of tools designed to manipulate on sets (arrays with unique elements)
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Transforms @p array into an unordered set (order of the
#     elements in the array is not kept)
#
# @param array
#    array to be transformed
# -------------------------------------------------------------------
function array_to_uset() {

    # Arguments
    local -n array_="$1"

    # Local variables
    local -A hash_array_

    # Produce a hash array which keys are the elements of the array_
    for elem in "${array_[@]}"; do
        hash_array_["$elem"]=""
    done

    # Substitute initial array with the set of hash array's keys
    array_=( "${!hash_array_[@]}" )

}

# -------------------------------------------------------------------
# @brief Transforms @p array into an ordered set (order of the
#     elements in the array is kept)
#
# @param array
#    array to be transformed
#
# @note This implementation is slow
# -------------------------------------------------------------------
function array_to_set() {

    # Arguments
    local -n array_="$1"

    # Local variables
    local -a out_array_

    # Check array's length
    (( ${#array_[@]} == 0 )) && return
    
    # Iterate over the source array
    for i in "${!array_[@]}"; do
    
        # If array's element was already met, continue
        is_array_element out_array_ "${array_[$i]}" && continue
        # Else, add element to the result array
        out_array_+=("${array_[$i]}")
        
    done
    
    # Substitute initial array with the set of hash array's keys
    array_=( "${out_array_[@]}" )

}
