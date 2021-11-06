#!/usr/bin/env bash
# ====================================================================================================================================
# @file     variables.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 2:36:03 am
# @modified Saturday, 6th November 2021 2:15:05 pm
# @project  BashUtils
# @brief
#    
#    Set of general utilities related to variables' manipulation
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @param var 
#    name of the variable to be inspected
#
# @returns 
#    @c 0 if @p var is defined in the calling context \n
#    @c 1 otherwise
# -------------------------------------------------------------------
is_var_set() {
    local var=$1
    # return $([[ -v  $var ]])    # Bash >= 4.2
    return $([[ -n  ${!var+x} ]]) # Portable
}

# -------------------------------------------------------------------
# @param var 
#    name of the variable to be inspected
#
# @returns 
#    @c 0 if @p var is defined to a non-zero string \n
#    @c 1 otherwise
# -------------------------------------------------------------------
is_var_set_non_empty() {
    local var=$1
    return $([[ -n  ${!var:+x} ]])
}

# -------------------------------------------------------------------
# @brief Sets @p var variable to the @p default value if @p var
#    is not set in the calling context
#
# @param var 
#    name of the variable to be set
# @param default 
#    default value of the variable
# -------------------------------------------------------------------
var_set_default() {

    local var=$1
    local default=$2

    eval "${var}=${!var:-$default}"
}

# -------------------------------------------------------------------
# @brief Prints variable with the @p var name in a 'name=value'
#    form
#
# @param var
#    variable to be printed
# -------------------------------------------------------------------
print_var() {

    # Arguments
    local var=$1

    # Print variable
    echo "$var=${!var}"
    
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
