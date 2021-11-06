#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 9:31:13 pm
# @modified Saturday, 6th November 2021 5:35:34 pm
# @project  BashUtils
# @brief
#    
#    Set of functions related to strings' manipulation
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Checks whether @p str string is equal to at leats one of
#    strings in the @p table
#
# @param str
#    string to be checked
# @param table
#    name of the table containing strings to be matched against
#
# @returns 
#    @c 0 if @p str was matched to at least one string from the
#         @p table \n
#    @c 1 otherwise
# -------------------------------------------------------------------
is_one_of() {

    # Arguments
    local str="$1"
    local -n table=$2

    # Compare strings
    for item in "${table[@]}"; do
        if [[ "$str" == "$item" ]]; then
            return 0
        fi
    done

    return 1
}
