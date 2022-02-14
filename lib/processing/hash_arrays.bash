#!/usr/bin/env bash
# ====================================================================================================================================
# @file     hash_arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Monday, 14th February 2022 5:54:27 pm
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

# -------------------------------------------------------------------
# @brief Checks whether hash array named @p harray has a field named
#    @p field defined
#
# @param harray
#    name fo the hash array to be verified
# @param field
#    field of the @p harray to be checked
#
# @returns
#    @c 0 if @p harray has a field names @p field
#    @c 1 otherwise
#    @c 2 if @p harray is not a hash array
# -------------------------------------------------------------------
function has_hash_array_field() {

    # Parse arguments
    local harray_="$1"
    local field_="$2"

    # Check if @p harray is a hash_array
    is_hash_array $harray_ || return 2

    # Get reference to the array
    local -n harray_ref="$harray_"
    # Check if @p field is defined
    [ ${harray_ref[$field_]+x} ] || return 1

    return 0
}