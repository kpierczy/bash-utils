#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ubad_list.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 14th February 2022 5:23:15 pm
# @modified Monday, 21st February 2022 6:58:11 pm
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
#    @retval @c 0 if entity named @p entity is a valid UBAD list 
#    @retval @c 1 otherwise
#    @retval @c 2 if invalid @p argtype is given
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
    for ubad_table_name_ in "${array_[@]}"; do
        
        # Check if name refers to a valid UBAd table
        is_ubad_table "$ubad_table_name_" "$argtype_" || return $?

    done

    return 0
}


# ---------------------------------------------------------------------------------------
# @brief Checks whether an UBAD list has a UBAD table with the given name 
#
# @param list
#    name of the UBAD list
# @param name
#    name to be found
# @returns 
#    @retval @c 0 if requested table has been found
#    @retval @c 1 otherwise
#    @retval @c 2 if list is not an array
# ---------------------------------------------------------------------------------------
function has_ubad_list_table_with_name() {

    # Get reference to the UBAD lsit
    local list_="$1"
    # Get type the table to be checked
    local name_="$2"

    # -------------------------- Validate arguments ---------------------------

    # Check if @p list_ is an array
    is_hash_array "$list_" || return 2

    # ------------------------------ Parse envs -------------------------------

    # Get reference to the UBAD list
    local -n __list_ref_="$list_"

    local table_

    # Iterate over UBAD list
    for table_ in "${__list_ref_[@]}"; do

        # Get reference to the UBAD table of the given env
        local -n table__ref_="$table_"

        # Get name of the env
        local __parseenvs_parse_envs_env_name_="${__parseenvs_parse_envs_env_def_ref_[name]}"

        # If name matches, return success
        if [[ "$__parseenvs_parse_envs_env_name_" == "$name_" ]]; then
        
            return 0
        fi

    done

    # -------------------------------------------------------------------------

    # By default return error 
    return 1
}