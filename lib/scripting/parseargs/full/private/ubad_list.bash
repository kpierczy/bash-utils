#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ubad_list.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 14th February 2022 5:23:15 pm
# @modified Thursday, 17th February 2022 3:51:48 pm
# @project  bash-utils
# @brief
#    
#    
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a valid UBAD list of the 
#    @p argtype typed arguments
#
# @param entity
#    name of the entity to be inspected
# @param argtype
#    type of the arguments described by the inspected UBAD list (one of [pargs, opts,
#    envs])
# @returns 
#    @c 0 if entity named @p entity is a valid UBAD list \n
#    @c 1 otherwise
#    @c 2 if invalid @p argtype is given
# ---------------------------------------------------------------------------------------
function is_ubad_list() {

    # Get reference to the entity
    local entity_="$1"
    # Get type the table to be checked
    local argtype_="$2"

    # ----------- Validate arguments ------------

    # Check if @p entity is an array
    is_array "$entity_" || return 2

    # -------------------------------------------

    # Get reference to the array
    local -n array_="$entity_"

    local ubad_table_name_

    # Iterate over names of UBAD tables contained by the UBAD list
    for ubad_table_name_ in ${array_[@]}; do

        # Check if name refers to a valid UBAd table
        is_ubad_table "$ubad_table_name_" "$argtype_" || return $?

    done

    return 0
}
