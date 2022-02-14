#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ubad_table.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 3:13:57 pm
# @modified Monday, 14th February 2022 8:54:35 pm
# @project  bash-utils
# @brief
#    
#    
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Checks whether optional field of the UBAD table entity named @p entity are valid
#    (if present)
#
# @param entity
#    name of the entity to be inspected
# @returns 
#    @c 0 if entity named @p entity is a valid UBAD table \n
#    @c 1 otherwise
#    @c 2 if invalid @p entity is given
# ---------------------------------------------------------------------------------------
function are_optional_fields_of_ubad_table_valid() {

    # Parse entitie's name
    local entity_="$1"

    # ----------- Validate arguments ------------

    # Check if @p entity is an array
    is_hash_array "$entity_" || return 2

    # -------------------------------------------

    # Check whether [type] field is valid (if defined)
    ! has_hash_array_field "$entity_" "type" || is_ubad_arg_type "${harray_[type]}" || return 1

    # Assume default type of the field
    local type_="string"
    # Get type of the field if given
    has_hash_array_field "$entity_" "type" && type_="${harray_[type]}"

    # Perform additional check only for integer-typed argument
    if is_any_of "$type_" 'i' 'integer'; then

        # Check whether [default] field is valid (if defined)
        has_hash_array_field "$entity_" "default" || is_ubad_integer "${harray_[default]}" || return 1

        # Limit modifications of the IFS word-splitter to the local scope
        localize_word_splitting
        
        # Check whether [variants] field is valid (if defined)
        if has_hash_array_field "$entity_" "variants"; then

            # Get enumerated variants
            local variants_="${harray_[default]}"

            # Set world-splitting-separator to ' ' + '|' automaticaly parse option's names
            IFS='|'
            # Set positional arguments to the option's names
            set -- $variants_

            # A single variant
            local variant_

            # Iterate variants and check if they are integers
            for variant_ in "$@"; do
                is_ubad_integer "${variant_}" || return 1
            done
        
        # Otherwise, check whether [range] field is valid (if defined)
        elif has_hash_array_field "$entity_" "range"; then

            # Assert range has valid form
            [[ "${harray_[range]}" == *:* ]] || rteurn 1

            # Get range's string
            local range_="${harray_[range]}"
            # Get range's limits
            local min_="${range_%:*}"
            local max_="${range_#*:}"

            # Check if both values are integers
            is_ubad_integer "${min_}" || return 1
            is_ubad_integer "${max_}" || return 1
            
        fi

    fi

    return 0
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a valid UBAD table of the 
#    positional argument
#
# @param entity
#    name of the entity to be inspected
# @returns 
#    @c 0 if entity named @p entity is a valid UBAD table \n
#    @c 1 otherwise
#    @c 2 if invalid @p entity is given
# ---------------------------------------------------------------------------------------
function is_positional_arg_ubad_table() {

    # Parse entitie's name
    local entity_="$1"

    # ----------- Validate arguments ------------

    # Check if @p entity is an array
    is_hash_array "$entity_" || return 2

    # -------------------------------------------

    # Get reference to the hash array
    local -n harray_="$entity_"

    # Check whether [format] field is valid (if defined)
    ! has_hash_array_field "$entity_" "format" || is_ubad_positional_arg_format "${harray_[format]}" || return 1
    # Check whether [name] field is valid (if defined)
    ! has_hash_array_field "$entity_" "name" || is_ubad_identifier "${harray_[format]}" || return 1

    # Check if optional fields are valid
    return $(are_optional_fields_of_ubad_table_valid "$entity_")
}


# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a valid UBAD table of the 
#    optional argument
#
# @param entity
#    name of the entity to be inspected
# @returns 
#    @c 0 if entity named @p entity is a valid UBAD table \n
#    @c 1 otherwise
#    @c 2 if invalid @p entity is given
# ---------------------------------------------------------------------------------------
function is_optional_arg_ubad_table() {

    # Parse entitie's name
    local entity_="$1"

    # ----------- Validate arguments ------------

    # Check if @p entity is an array
    is_hash_array "$entity_" || return 2

    # -------------------------------------------
    
    # Get reference to the hash array
    local -n harray_="$entity_"

    # Check whether [format] field is defined and valid
    has_hash_array_field "$entity_" "format" && is_ubad_optional_arg_format "${harray_[format]}" || return 1
    # Check whether [name] field is defined and valid
    has_hash_array_field "$entity_" "name" && is_ubad_identifier "${harray_[name]}" || return 1

    # Check if optional fields are valid
    are_optional_fields_of_ubad_table_valid "$entity_" || return 1
}


# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a valid UBAD table of the 
#    environmental argument
#
# @param entity
#    name of the entity to be inspected
# @returns 
#    @c 0 if entity named @p entity is a valid UBAD table \n
#    @c 1 otherwise
#    @c 2 if invalid @p entity is given
# ---------------------------------------------------------------------------------------
function is_environmental_argubad_table() {

    # Parse entitie's name
    local entity_="$1"

    # ----------- Validate arguments ------------

    # Check if @p entity is an array
    is_hash_array "$entity_" || return 2

    # -------------------------------------------

    # Get reference to the hash array
    local -n harray_="$entity_"

    # Check whether [format] field is defined and valid
    has_hash_array_field "$entity_" "format" && is_ubad_identifier "${harray_[format]}" || return 1
    # Check whether [name] field is defined and valid
    has_hash_array_field "$entity_" "name" && is_ubad_identifier "${harray_[format]}" || return 1

    # Check if optional fields are valid
    return $(are_optional_fields_of_ubad_table_valid "$entity_")
}


# ---------------------------------------------------------------------------------------
# @brief Checks whether a bash entity named @p entity is a valid UBAD table of the 
#    @p argtype typed arguments
#
# @param entity
#    name of the entity to be inspected
# @param argtype
#    type of the arguments described by the inspected UBAD list (one of [pargs, opts,
#    envs])
# @returns 
#    @c 0 if entity named @p entity is a valid UBAD table \n
#    @c 1 otherwise
#    @c 2 if invalid @p entity or @p argtype is given
# ---------------------------------------------------------------------------------------
function is_ubad_table() {

    # Get reference to the entity
    local entity_="$1"
    # Get type the table to be checked
    local argtype_="$2"

    # ----------- Validate arguments ------------

    # Check if @p entity is an array
    is_hash_array "$entity_" || return 2

    # -------------------------------------------

    # Check if valid type given
    case "${argtype_}" in
        "pargs" ) is_positional_arg_ubad_table   "$entity_"; return $? ;;
        "opts"  ) is_optional_arg_ubad_table     "$entity_"; return $? ;;
        "envs"  ) is_environmental_argubad_table "$entity_"; return $? ;;
        *       ) return 2 ;;
    esac

}
