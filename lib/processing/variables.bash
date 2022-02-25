#!/usr/bin/env bash
# ====================================================================================================================================
# @file     variables.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 2:36:03 am
# @modified Thursday, 24th February 2022 5:16:09 pm
# @project  bash-utils
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
#    @retval @c 0 if @p var is defined in the calling context 
#    @retval @c 1 otherwise
# -------------------------------------------------------------------
function is_var_set() {
    local var=$1
    # return $([[ -v  $var ]])   # Bash >= 4.2
    return $([[ -n ${!var+x} ]]) # Portable
}

# -------------------------------------------------------------------
# @param var 
#    name of the variable to be inspected
#
# @returns 
#    @retval @c 0 if @p var is defined to a non-zero string 
#    @retval @c 1 otherwise
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
    local __print_var_var_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a __print_var_opt_definitions_=(
        '-n|--name',name,f
    )
    
    # Parse arguments to a named array
    local -a __print_var_args_=( "$@" )

    # Prepare names hash arrays for positional arguments and parsed options
    local -a __print_var_posargs_=()
    local -A __print_var_options_=()

    # Parse options
    parseopts_s                      \
        __print_var_args_            \
        __print_var_opt_definitions_ \
        __print_var_options_         \
        __print_var_posargs_         \
    || return 1

    # Parse arguments
    __print_var_var_="${__print_var_posargs_[0]}"

    # ------------------------------------------------- 

    # Print variable
    is_var_set __print_var_options_[name] &&
        echo "$__print_var_var_=${!__print_var_var_}" ||
        echo "${!__print_var_var_}"
    
}
