#!/usr/bin/env bash
# ====================================================================================================================================
# @file     functions.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 9:47:05 pm
# @modified Wednesday, 10th November 2021 6:41:12 pm
# @project  BashUtils
# @brief
#    
#    Set of functions related to - wait for it - functions
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Checks whether @p fun is defined
#
# @brief fun
#    name of the function to be checked
# -------------------------------------------------------------------
function is_function_defined() {

    # Arguments
    local fun=$1

    # Check if defined
    [[ $(type -t $fun) == function ]]
    
}
