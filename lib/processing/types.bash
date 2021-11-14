#!/usr/bin/env bash
# ====================================================================================================================================
# @file     types.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 1:12:37 pm
# @modified Sunday, 14th November 2021 6:56:19 pm
# @project  BashUtils
# @brief
#    
#    Set of simple tools related to the inspection of the type of the bash entity
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Writes space-separated list of attributes of the bash entity (variable, 
#    function, array, etc.) named @p entity to the stdout
#
# @param entity
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist
#
# @brief The space of variables is searched BEFORE the space of functions
# ---------------------------------------------------------------------------------------
function get_entity_type() {

    # Arguments
    local entity_="$1"

    # Local variables
    local entity_info_
    local attributes_

    # Get informations about the entity
    entity_info_="$(declare -p  $entity_ 2> /dev/null)" || 
    entity_info_="$(declare -pF $entity_ 2> /dev/null)" || return 1    

    # Parse list of attributes from the info string
    [[ "$entity_info_" =~ -[[:alpha:]-]+ ]] || return 1
    # Get the result
    attributes_="${BASH_REMATCH[0]}"
    # Remove the leading dash
    attributes_="${attributes_#-}"

    # Print list to the output
    echo "$(echo $attributes_ | awk '$1=$1' FS='' OFS=' ')"

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a simple string
#
# @param variable
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist \n
#    @c 2 if entity is not a string
# ---------------------------------------------------------------------------------------
function is_string() {

    # Arguments
    local entity_="$1"

    # List of entitie's attributes
    local attributes_
    # Get list of entitie's attributes
    attributes_="$(get_entity_type $1)" || return 1

    # Check if entity is undefined type (hence, assume it's string)
    is_substring "$attributes_" "-" || return 1
    # Check if entity is NOT an integer
    ! is_substring "$attributes_" "i" || return 1
    # Check if entity is NOT an array
    ! is_substring "$attributes_" "a" || return 1
    # Check if entity is NOT an assosiative array
    ! is_substring "$attributes_" "A" || return 1

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a string
#
# @param entity
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist \n
#    @c 2 if entity is not a string
# ---------------------------------------------------------------------------------------
function is_string() {

    # Arguments
    local entity_="$1"

    # List of entitie's attributes
    local attributes_
    # Get list of entitie's attributes
    attributes_="$(get_entity_type $1)" || return 1

    # Check if entity is undefined type (hence assume it's string)
    is_substring "$attributes_" "-" || return 2
    # Check if entity is NOT an integer
    ! is_substring "$attributes_" "i" || return 2
    # Check if entity is NOT an array
    ! is_substring "$attributes_" "a" || return 2
    # Check if entity is NOT an assosiative array
    ! is_substring "$attributes_" "A" || return 2

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is an integer
#
# @param entity
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist \n
#    @c 2 if entity is not an integer
# ---------------------------------------------------------------------------------------
function is_integer() {

    # Arguments
    local entity_="$1"

    # List of entitie's attributes
    local attributes_
    # Get list of entitie's attributes
    attributes_="$(get_entity_type $1)" || return 1

    # Check if entity is undefined type (hence assume it's string)
    is_substring "$attributes_" "i" || return 2
    # Check if entity is NOT an array
    ! is_substring "$attributes_" "a" || return 2
    # Check if entity is NOT an assosiative array
    ! is_substring "$attributes_" "A" || return 2

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is an array
#
# @param entity
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist \n
#    @c 2 if entity is not an array
# ---------------------------------------------------------------------------------------
function is_array() {

    # Arguments
    local entity_="$1"

    # List of entitie's attributes
    local attributes_
    # Get list of entitie's attributes
    attributes_="$(get_entity_type $1)" || return 1

    # Check if entity is NOT an array
    ! is_substring "$attributes_" "a" || return 2

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is an hash array
#
# @param entity
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist \n
#    @c 2 if entity is not an hash array
# ---------------------------------------------------------------------------------------
function is_hash_array() {

    # Arguments
    local entity_="$1"

    # List of entitie's attributes
    local attributes_
    # Get list of entitie's attributes
    attributes_="$(get_entity_type $1)" || return 1

    # Check if entity is NOT an array
    ! is_substring "$attributes_" "A" || return 2

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is an function
#
# @param entity
#    name of the entity to be inspected
#
# @returns
#    @c 0 on succes \n
#    @c 1 if entity does not exist \n
#    @c 2 if entity is not a function
# ---------------------------------------------------------------------------------------
function is_function() {

    # Arguments
    local entity_="$1"

    # List of entitie's attributes
    local attributes_
    # Get list of entitie's attributes
    attributes_="$(get_entity_type $1)" || return 1

    # Check if entity is NOT an array
    ! is_substring "$attributes_" "f" || return 2

    return 0
}
