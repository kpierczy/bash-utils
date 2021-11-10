#!/usr/bin/env bash
# ====================================================================================================================================
# @file     hash_arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Tuesday, 9th November 2021 5:42:29 pm
# @project  BashUtils
# @brief
#    
#    Set of tools related to bash hash arrays
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Prints array with name passed as @p arr argument
#
# @param arr
#    name fo the array to be printed
# -------------------------------------------------------------------
print_hash_array() {

    # Arguments
    local -n arr="$1"

    # Print array
    for key in "${!arr[@]}"; do 
        printf "%s=%s\n" "$key" "${arr[$key]}"
    done

}
