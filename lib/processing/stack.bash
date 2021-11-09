#!/usr/bin/env bash
# ====================================================================================================================================
# @file     stack.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 9:00:58 pm
# @modified Tuesday, 9th November 2021 1:01:24 am
# @project  BashUtils
# @brief
#    
#    Bash implementation of simple stack mechanisms
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ========================================================== Configuration ========================================================= #

# Prefix of the stack's variables
declare STACK_PREFIX="__"
# Suffix of the string stack's array
declare STACK_SUFFIXFIX="_stack__"
# Name of the default stack
declare DEFAULT_STACK_NAME="default"

# ============================================================ Variables =========================================================== #

# Default string stack
declare -a "${STACK_PREFIX}${DEFAULT_STACK_NAME}${STACK_SUFFIXFIX}=()"

# ========================================================= Helper aliases ========================================================= #

# -------------------------------------------------------------------
# @brief Helper alias setting variables @var stack_name_ (name of
#    the array variable implementing the stack) assuming that the
#    processed stack's name is @var stack_name_
#    
# @environment
#
#    stack_name_  name of the stack to be processed
#
# @provides
#
#    stack_name_      name of the array variable implementing the 
#                     stack
#    
# -------------------------------------------------------------------
alias set_stack_name_var='
# Set full name of the stack
stack_name_="${STACK_PREFIX}${stack_name_}${STACK_SUFFIXFIX}"
'

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Pushes @p elem to the stack named @p stack_name. If no 
#    stack with @p stack_name name exists it will be created
# 
# @param stack_name (optional)
#    name of the destination stack ; if no @p stack_name is given,
#    @p elem will be pushed to the default stack
# @param elem
#    element to be pushed to the stack
#
# @returns
#    @c 0 on success \n
#    @c 1 if no argument was given
# -------------------------------------------------------------------
function push_stack() {

    # Arguments
    local stack_name_
    local elem_

    # Check number of arguments
    [[ $# == "0" ]] && return 1

    # Parse arguments
    if (( $# == 1 )); then

        # Set default stack
        stack_name_="${DEFAULT_STACK_NAME}"
        # Parse value to be pushed
        elem_="$1"

    else

        # Set default stack
        stack_name_="${1}"
        # Parse value to be pushed
        elem_="$2"

    fi
    
    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, create one
    if ! [[ -v "$stack_name_"[@] ]]; then
        declare -ga "${stack_name_}"
    fi

    # Set references to the stack's variables
    local -n stack_ref_="$stack_name_"
    
    # Push element to the stack
    stack_ref_+=("$elem_")

}

# -------------------------------------------------------------------
# @brief Pops an element from the stack named @p stack_name and places
#    it in the variable named @p result. 
#
# @param stack_name (optional)
#    name of the stack to pop element from; if not given, string
#    will be popped from the default string stack
# @param result
#    name of the variable that should store the pop result; if 
#    return status is not @c 0, @p result variable is not modified
#
# @returns 
#    @c 0 on success \n
#    @c 1 if string stack with @p stack_name name doesn't exist \n
#    @c 2 if string stack named @p stack_name is empty
# -------------------------------------------------------------------
function pop_stack() {

    # Arguments
    local stack_name_
    local result_

    # Parse arguments
    if [[ $# == "1" ]]; then
        stack_name_="${DEFAULT_STACK_NAME}"
        result_="$1"
    else
        stack_name_="$1"
        result_="$2"
    fi

    # Get reference to the result
    local -n result_ref_="$result_"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Set references to the stack's variables
    local -n stack_ref_="$stack_name_"

    # If stack is empty, return error
    (( ${#stack_ref_[@]} != 0 )) || return 2
    
    # Write out last element of the stack 
    result_ref_="${stack_ref_[-1]}"

    # Remove element from the stack
    unset stack_ref_[-1]

}

# -------------------------------------------------------------------
# @brief Resets stack named @p stack_name removing it's all elements
#
# @param stack_name (optional)
#    name of the stack to be reset; if not given, the default stack
#    will be given
#
# @returns 
#    @c 0 on success \n
#    @c 1 if stack named @p stack_name does not exist
# -------------------------------------------------------------------
function reset_stack() {

    # Arguments
    local stack_name_="${1:-${DEFAULT_STACK_NAME}}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Set references to the stack's variables
    local -n stack_ref_="$stack_name_"

    # Reset stack's size
    unset stack_ref_
    declare -ga "${stack_name_}"

}

# -------------------------------------------------------------------
# @brief Removes stack named @p stack_name
#
# @param stack_name
#    name of the string stack to be removed
#
# @returns 
#    @c 0 on success \n
#    @c 1 if no string stack named @p stack_name exists \n
#    @c 2 if no argument was given
# -------------------------------------------------------------------
function destroy_stack() {

    # Arguments
    local stack_name_

    # If no argument given, return error
    [[ $# == "0" || -z "$1" ]] && return 2

    # Parse stack's name
    stack_name_="$1"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Remove the stack
    unset $stack_name_

}

# -------------------------------------------------------------------
# @brief Prints content of the stack named @p stack_name
#
# @param stack_name (optional)
#    name of the stack to be printed; if no @p stack_name is given,
#    content of the default stack will be printed
#
# @returns 
#    @c 0 on success \n
#    @c 1 if no stack named @p stack_name exists
# -------------------------------------------------------------------
function print_stack() {

    # Arguments
    local stack_name_="${1:-${DEFAULT_STACK_NAME}}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Print stack's content
    print_array "$stack_name_"
    
}

# -------------------------------------------------------------------
# @param stack_name
#    name of the stack to be inspected
#
# @returns 
#    @c 0 if stack named @p stack_name exists \n
#    @c 1 if no stack named @p stack_name exists
# -------------------------------------------------------------------
function is_stack() {

    # Arguments
    local stack_name_

    # If no argument given, return error
    [[ $# == "0" || -z "$1" ]] && return 1

    # Parse stack's name
    stack_name_="$1"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] && return 0 || return 1

}

# -------------------------------------------------------------------
# @brief Writes current size of the stack named @p stack_name to the
#    stdout if it exists
#
# @param stack_name
#    name of the stack to be inspected
#
# @returns 
#    @c 0 if stack named @p stack_name exists \n
#    @c 1 if no stack named @p stack_name exists
# -------------------------------------------------------------------
function get_stack_size() {

    # Arguments
    local stack_name_

    # If no argument given, return error
    [[ $# == "0" || -z "$1" ]] && return 1

    # Parse stack's name
    stack_name_="$1"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] ||  return 1

    # Set references to the stack's variables
    local -n stack_ref_="$stack_name_"

    # Write out stack's size
    echo "${#stack_ref_[@]}"

}

