#!/usr/bin/env bash
# ====================================================================================================================================
# @file     hash_arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Saturday, 13th November 2021 2:25:06 am
# @project  bash-utils
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
#
# @options
#
#    -n|--name  if given, name of the array is printed
#
# -------------------------------------------------------------------
function print_hash_array() {

    # Arguments
    local -n arr_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-n|--name',name,f
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    arr_="${posargs[0]}"

    # ------------------------------------------------- 

    # Print name of the array
    is_var_set options[name] && echo "${posargs[0]}:"
    
    # Print array
    for key in "${!arr_[@]}"; do 
        printf "[%s]=%s\n" "$key" "${arr_[$key]}"
    done

}
