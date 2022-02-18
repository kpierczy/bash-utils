#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseenvs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 12:49:58 pm
# @modified Friday, 18th February 2022 8:18:35 pm
# @project  bash-utils
# @brief
#    
#    Set of functions used to implement 'parseenvs'
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Based on the definitions finds format of the env 
#    corresponding to the name env in the UBAD table
#
# @params envs_defs
#    list of valid options' definitions
# @param env_name
#    name of the option to be matched
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 if name does not correspond to any UBAd table on the list
# ---------------------------------------------------------------------------------------
function get_env_format() {

    # Arguments
    local -n __get_env_format_defs_="$1"
    local  __get_env_format_name_="$2"

    local env_def=""

    # Search a list of definitions to find name(s) corresponding to the given key
    for env_def in "${__get_env_format_defs_[@]}"; do

        # Get reference to the UBAD table
        local -n env_def_ref="$env_def"

        # If requred table has been found, break
        if [[ "${opt_def_ref[name]}" == "$__get_env_format_name_" ]]; then
            echo "${opt_def_ref[format]}"
            return 0
        fi

    done

    # If no option found, return error
    return 1
}

# ========================================================= Implementations ======================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses env arguments
#
# @param envs_defs
#    name of the UBAD list containing envs' definitions
# @param flag_def_type
#    verbosity mode (either 'defined' or 'undefined')
# @param envs_types [out]
#    name of the hash array holding pairs envname-envtype (every name has it's type
#    defined here)
# @param envs [out]
#    name of the hash array holding values of actually parsed envs (envs's whose
#    names have no defined value inside this array has not been parsed)
#
# @returns 
#    @c 0 on success \n
#    @c 1 if function sufferred from the bug \n
#    @c 2 if invalid option has been passed \n
#    @c 4 if invalid UBAD list has been given
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function (i.e. `parseargs`)
# ---------------------------------------------------------------------------------------
function parseenvs_parse_envs() {

    # Parse arguments
    local    __parseenvs_parse_envs_envs_defs_="$1"
    local    __parseenvs_parse_envs_flag_def_type_="$2"
    local -n __parseenvs_parse_envs_env_types_="$3"
    local -n __parseenvs_parse_envs_envs_="$4"

    # ------------------------------ Parse envs -------------------------------

    # Get reference to the UBAD list
    local -n __parseenvs_parse_envs_envs_defs_ref_="$__parseenvs_parse_envs_envs_defs_"

    local __parseenvs_parse_envs_env_def_

    # Iterate over UBAD list
    for __parseenvs_parse_envs_env_def_ in "${__parseenvs_parse_envs_envs_defs_ref_[@]}"; do

        # Get reference to the UBAD table of the given env
        local -n __parseenvs_parse_envs_env_def_ref_="$__parseenvs_parse_envs_env_def_"

        # Get name of the env
        local __parseenvs_parse_envs_env_name_="${__parseenvs_parse_envs_env_def_ref_[name]}"

        # Save type of the env to the output array
        if is_var_set __parseenvs_parse_envs_env_def_ref_[type]; then

            # Get type of the env
            local __parseenvs_parse_envs_env_type_="${__parseenvs_parse_envs_env_def_ref_[type]}"
            # Keep the type
            __parseenvs_parse_envs_env_types_["$__parseenvs_parse_envs_env_name_"]="$__parseenvs_parse_envs_env_type_"

        # If not defined, set default (string)
        else
            __parseenvs_parse_envs_env_types_["$__parseenvs_parse_envs_env_name_"]="string"
        fi

        # If requested env is defined, parse it
        if is_var_set "${__parseenvs_parse_envs_env_def_ref_[format]}"; then

            # Get reference to the env
            local -n __parseenvs_parse_envs_env_ref_="${__parseenvs_parse_envs_env_def_ref_[format]}"

            # If env is a flag argument, perform special parsing
            if is_ubad_arg_flag "${__parseenvs_parse_envs_env_types_[$__parseenvs_parse_envs_env_name_]}"; then

                # Parse flag only if it is set to '1'
                if [[ "$__parseenvs_parse_envs_env_ref_" == "1" ]]; then
                    __parseenvs_parse_envs_envs_["$__parseenvs_parse_envs_env_name_"]="0"
                fi

            # For other types, just parse value of the env
            else
                __parseenvs_parse_envs_envs_["$__parseenvs_parse_envs_env_name_"]="$__parseenvs_parse_envs_env_ref_"
            fi

        # Else, if env is not set, check if flag option is being parse
        elif is_ubad_arg_flag "${__parseenvs_parse_envs_env_types_[$__parseenvs_parse_envs_env_name_]}"; then
            # If 'unpresent flags define' option is set, define option as unparsed
            if [[ "${__parseenvs_parse_envs_flag_def_type_}" == "defined" ]]; then
                __parseenvs_parse_envs_envs_["$__parseenvs_parse_envs_env_name_"]="1"
            fi
        fi

    done

    # -------------------------------------------------------------------------

    return 0
}

# ========================================================== Helpe printer ========================================================= #

# ---------------------------------------------------------------------------------------
# @brief Automatically generates description of envs arguments based on the UBAD list
#
# @param envs_defs
#    name of the UBAD list containing envs arguments' definitions
# ---------------------------------------------------------------------------------------
function generate_envs_description() {   

    # Parse arguments
    local __generate_envs_description_opt_envs_="$1"

    # ------------------------ Format the description -------------------------
    
    # Prepare outpt hash array for formats
    local -A formats=()
    # Prepare outpt hash array for helps
    local -A helps=()
    # Prepare outpt hash array for types
    local -A types=()
    
    local opt_def=""

    # Parse formats and helps
    parse_description_info                       \
        "$__generate_envs_description_opt_envs_" \
        formats helps types
    
    # Compile description text
    compile_description_info formats helps

    # -------------------------------------------------------------------------
}

# ================================================================================================================================== #
