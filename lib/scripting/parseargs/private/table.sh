#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ubad_parsing.sh
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 2:24:35 pm
# @modified Sunday, 14th November 2021 2:47:00 pm
# @project  bash-utils
# @brief
#    
#    List of functions related to parsing process of the UBAD table
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Function ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Checks whether @p string is a valid type identifier of the argument
#
# @param string
#    string to be inspected
# @returns 
#    @c 0 if @p string is a valid argument's type \n
#    @c 1 otherwise
# ---------------------------------------------------------------------------------------
function is_ubad_arg_type() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        "string"  | "s" ) return 0 ;;
        "integer" | "i" ) return 0 ;;
        "flag"    | "f" ) return 0 ;;
        "path"    | "p" ) return 0 ;;
        *               ) return 1 ;;
    esac

}


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
# ---------------------------------------------------------------------------------------

# function is_ubad_list() {}
