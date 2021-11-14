#!/usr/bin/env bash
# ====================================================================================================================================
# @file     options.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 1:47:09 pm
# @modified Sunday, 14th November 2021 1:59:27 pm
# @project  BashUtils
# @brief
#    
#    Helper functions related to optional arguments
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a short option (in sense
#    of the `getopt` tool, i.e. if it is a letter with a single
#    leading dash)
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is a short option \n
#    @c 1 otheriwse
# -------------------------------------------------------------------
function is_short_option() {

    # Arguments
    local string_="$1"

    # Check if a short option
    [[ ${#string_} == "2" ]] &&
    [[ ${string_:0:1} == "-" ]] &&
    [[ ${string_:1:1} =~ [[:alpha:]] ]] ||
    # If not, return error
    return 1

    # If a valid short option, return success
    return 0

}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a long option (in sense
#    of the `getopt` tool, i.e. if it is a non-empty string with 
#    a double leading dash)
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is a long option \n
#    @c 1 otheriwse
# -------------------------------------------------------------------
function is_long_option() {

    # Arguments
    local string_="$1"

    # Check if a long option
    starts_with "$string_ " "--" && 
    [[ ${string_:2} =~ [[:alpha:]-]+ ]] ||
    # If not, return error
    return 1

    # If a valid long option, return success
    return 0

}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a short or a long option
#
# @param string
#    string to be inspected
#
# @returns 
#    @c 0 if @p string is an option \n
#    @c 1 otheriwse
#
# @see is_short_option
# @see is_long_option
# -------------------------------------------------------------------
function is_option() {

    # Arguments
    local string_="$1"

    # Check if an option
    is_short_option string_ || is_long_option string_

}
