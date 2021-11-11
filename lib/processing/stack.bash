#!/usr/bin/env bash
# ====================================================================================================================================
# @file     stack.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 9:00:58 pm
# @modified Thursday, 11th November 2021 2:22:23 am
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
# @brief Pushes @p elem to the stack. If the given stack doesn't
#    exists it will be created
# 
# @param elem
#    element to be pushed to the stack
#
# @returns
#    @c 0 on success \n
#    @c 1 if no argument was given or on error
#
# @options
#
#   -s|--stack-name=NAME  name of the destination stack; if not
#                         given, the default stack will be used
# 
# -------------------------------------------------------------------
function push_stack() {

    # Arguments
    local elem_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse options
    parse_options

    # Check number of arguments
    [[ ${#posargs[@]} == "0" ]] && return 1

    # Parse arguments
    elem_="${posargs[0]:-}"

    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"
    
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
# @brief Pops an element from the stack and places it in the
#    variable named @p result. 
#
# @param result
#    name of the variable that should store the pop result; if 
#    return status is not @c 0, @p result variable is not modified
#
# @returns 
#    @c 0 on success \n
#    @c 1 if string stack doesn't exist \n
#    @c 2 if string stack is empty
#
# @options
#
#   -s|--stack-name=NAME  name of the source stack; if not
#                         given, the default stack will be used
#
# -------------------------------------------------------------------
function pop_stack() {

    # Arguments
    # local result_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse options
    parse_options

    # Check number of arguments
    [[ ${#posargs[@]} == "0" ]] && return 1

    # Parse arguments
    local -n result_="${posargs[0]}"
    
    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Set references to the stack's variables
    local -n stack_ref_="$stack_name_"

    # If stack is empty, return error
    (( ${#stack_ref_[@]} != 0 )) || return 2
    
    # Write out last element of the stack 
    result_="${stack_ref_[-1]}"    

    # Remove element from the stack
    unset stack_ref_[-1]

}

# -------------------------------------------------------------------
# @brief Resets a stack removing it's all elements
#
# @returns 
#    @c 0 on success \n
#    @c 1 if stack does not exist
#
# @options
#
#   -s|--stack-name=NAME  name of the target stack; if not
#                         given, the default stack will be used
#
# -------------------------------------------------------------------
function reset_stack() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse arguments to a named array
    parse_options
    
    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"

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
# @brief Removes stack
#
# @returns 
#    @c 0 on success \n
#    @c 1 if the stack doesn't exists
#
# @options
#
#   -s|--stack-name=NAME  name of the target stack; if not
#                         given, the default stack will be used
#
# -------------------------------------------------------------------
function destroy_stack() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Remove the stack
    unset $stack_name_

}

# -------------------------------------------------------------------
# @brief Prints content of the stack
#
# @returns 
#    @c 0 on success \n
#    @c 1 if the stack doesn't exists
#
# @options
#
#   -s|--stack-name=NAME  name of the target stack; if not
#                         given, the default stack will be used
#
# -------------------------------------------------------------------
function print_stack() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] || return 1

    # Print stack's content
    print_array "$stack_name_"
    
}

# -------------------------------------------------------------------
# @brief Checks if the stack exists
#
# @returns 
#    @c 0 if stack named @p stack_name exists \n
#    @c 1 if no stack named @p stack_name exists
#
# @options
#
#   -s|--stack-name=NAME  name of the target stack; if not
#                         given, the default stack will be used
#
# -------------------------------------------------------------------
function is_stack() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] && return 0 || return 1

}

# -------------------------------------------------------------------
# @brief Writes current size of the stack to the stdout if it exists
#
# @returns 
#    @c 0 if stack exists \n
#    @c 1 if stack doesn't exist
#
# @options
#
#   -s|--stack-name=NAME  name of the target stack; if not
#                         given, the default stack will be used
#
# -------------------------------------------------------------------
function get_stack_size() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--stack-name',stack
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------------------------------------------

    local stack_name_

    # Establish destination stack
    is_var_set_non_empty options[stack] &&
        stack_name_="${options[stack]}" ||
        stack_name_="${DEFAULT_STACK_NAME}"

    # Set names of the array representing the stack
    set_stack_name_var

    # If stack does not exist, return error
    [[ -v "$stack_name_"[@] ]] ||  return 1

    # Set references to the stack's variables
    local -n stack_ref_="$stack_name_"

    # Write out stack's size
    echo "${#stack_ref_[@]}"

}

