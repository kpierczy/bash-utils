#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 4:50:15 pm
# @modified Tuesday, 9th November 2021 8:36:46 pm
# @project  BashUtils
# @brief
#    
#    Set of tools related to bash strings
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================


# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Checks whether @p string starts with a @p prefix
# 
# @param string
#    string to be checked
# @param prefix
#    prefix to be matched
#
# @returns 
#    @c 0 if true \n
#    @c 0 if false
# -------------------------------------------------------------------
function starts_with() {

    # Arguments
    local string_="$1"
    local prefix_="$2"

    # Check if string is not shorter than prefix
    (( ${#string_} >= ${#prefix_} )) || continue

    # Match first "${#prefix_}" characters of the string with the prefix
    [[ "${string_:0:${#prefix_}}" == "$prefix_" ]]

}

# -------------------------------------------------------------------
# @brief Checks whether @p string ends with a @p suffix
# 
# @param string
#    string to be checked
# @param suffix
#    suffix to be matched
#
# @returns 
#    @c 0 if true \n
#    @c 0 if false
# -------------------------------------------------------------------
function ends_with() {

    # Arguments
    local string_="$1"
    local suffix_="$2"

    # Check if string is not shorter than suffix
    (( ${#string_} >= ${#suffix_} )) || return 1

    # Match first "${#suffix_}" characters of the string with the suffix
    [[ "${string_: -${#suffix_}}" == "$suffix_" ]]

}

# -------------------------------------------------------------------
# @brief Checks whether @p substring is a substring of the @p string
# 
# @param string
#    string to be checked
# @param substring
#    substring to be matched
#
# @returns 
#    @c 0 if true \n
#    @c 0 if false
# -------------------------------------------------------------------
function is_substring() {

    # Arguments
    local string_="$1"
    local substring_="$2"

    # Check if is a substring
    [[ "$string_" == *"$substring_"* ]]

}
