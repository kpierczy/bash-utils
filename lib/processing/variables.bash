#!/usr/bin/env bash
# ====================================================================================================================================
# @file     variables.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 2:36:03 am
# @modified Friday, 12th November 2021 5:34:09 pm
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
function is_var_set() {
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
function is_var_set_non_empty() {
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
function var_set_default() {

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
#
# @options
#
#    -n|--name  if given, name of the variable is printed
#
# -------------------------------------------------------------------
function print_var() {

    # Arguments
    local var_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-n|--name',name,f
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    var_="${posargs[0]}"

    # ------------------------------------------------- 

    # Print variable
    is_var_set options[name] &&
        echo "$var_=${!var_}" ||
        echo "${!var_}"
    
}
