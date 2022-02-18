#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ubad_table.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 3:13:57 pm
# @modified Friday, 18th February 2022 7:28:50 pm
# @project  bash-utils
# @brief
#    
#    
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Checkers ============================================================ #

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
    if is_ubad_arg_integer "$type_"; then

        # Check whether [default] field is valid (if defined)
        ! has_hash_array_field "$entity_" "default" || is_ubad_integer "${harray_[default]}" || return 1
        
        # Check whether [variants] field is valid (if defined)
        if has_hash_array_field "$entity_" "variants"; then

            # Parse variants
            local parsed_variants
            parse_vatiants             \
                "${harray_[variants]}" \
                "default"              \
                parsed_variants

            local variant
            
            # Iterate variants and check if they are integers
            for variant in "${parse_vatiants[@]}"; do
                is_ubad_integer "${variant}" || return 1
            done
        
        # Otherwise, check whether [range] field is valid (if defined)
        elif has_hash_array_field "$entity_" "range"; then

            # Parse range's limits
            local min
            local max
            parse_range             \
                "${harray_[range]}" \
                "default"           \
                min max
                
            # Check if both values are integers
            is_ubad_integer "${min}" || return 1
            is_ubad_integer "${max}" || return 1
            
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

# ============================================================= Parsers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Parses a specific @p field from UBAD tables given in the @p definitions 
#    UBAD list and pairs them with argument's name
#
# @param definitions
#    name of the UBAD list containing definitions
# @param field
#    field to be parsed
# @param fields [out]
#    name of the has array that the fields will be written into
#
# @returns 
#    @c 0 on success \n
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function
# ---------------------------------------------------------------------------------------
function parse_ubad_tables_field() {

    # Parse arguments
    local -n __parse_ubad_tables_field_field_definitions_="$1"
    local    __parse_ubad_tables_field_field_field_="$2"
    local -n __parse_ubad_tables_field_field_fields_="$3"

    # ------------------------- Parse default values --------------------------

    local ubad_table

    # Get the field name
    local field="${__parse_ubad_tables_field_field_field_}"

    # Iterate over UBAD list
    for ubad_table in "${__parse_ubad_tables_field_field_definitions_[@]}"; do
        
        # Get reference to the table
        local -n ubad_table_ref="${ubad_table}"
        
        # If default value defined, write it down
        if is_var_set ubad_table_ref["$field"]; then
            
            # Get name of the argument
            local name="${ubad_table_ref[name]}"
            # Get value of the argument
            local value="${ubad_table_ref[$field]}"
            # Write the value down
            __parse_ubad_tables_field_field_fields_["$name"]="$value"

        fi

    done

    # -------------------------------------------------------------------------

    return 0   
}

# ---------------------------------------------------------------------------------------
# @brief Parses a specific @p field from UBAD tables given in the @p definitions 
#    UBAD list and pairs them with argument's name (skips flag-typed arguments)
#
# @param definitions
#    name of the UBAD list containing definitions
# @param field
#    field to be parsed
# @param fields [out]
#    name of the has array that the default values of non-flag argument will be written
#    into
#
# @returns 
#    @c 0 on success \n
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function
# ---------------------------------------------------------------------------------------
function parse_ubad_tables_field_no_flags() {

    # Parse arguments
    local -n __parse_ubad_tables_field_no_flags_field_definitions_="$1"
    local    __parse_ubad_tables_field_no_flags_field_field_="$2"
    local -n __parse_ubad_tables_field_no_flags_field_fields_="$3"

    # ------------------------- Parse default values --------------------------

    local ubad_table

    # Get the field name
    local field="${__parse_ubad_tables_field_no_flags_field_field_}"

    # Iterate over UBAD list
    for ubad_table in "${__parse_ubad_tables_field_no_flags_field_definitions_[@]}"; do
        
        # Get reference to the table
        local -n ubad_table_ref="${ubad_table}"
        
        # If flag option met, continue
        is_var_set ubad_table_ref[type] && is_ubad_arg_flag "${ubad_table_ref[type]}" &&
            continue
        # If default value defined, write it down
        if is_var_set ubad_table_ref["$field"]; then
            
            # Get name of the argument
            local name="${ubad_table_ref[name]}"
            # Get value of the argument
            local value="${ubad_table_ref[$field]}"
            # Write the value down
            __parse_ubad_tables_field_no_flags_field_fields_["$name"]="$value"

        fi

    done

    # -------------------------------------------------------------------------

    return 0   
}

# ---------------------------------------------------------------------------------------
# @brief Parses list of variants associated with the argument
#
# @param string
#    string containing list of variants
# @param parse_mode
#    parse mode (either 'default' - list element's will be trimmed - or 'raw' - list 
#    element's will NOT be trimmed)
# @param variants [out]
#    name of the array that the parsed variants will be written into
# ---------------------------------------------------------------------------------------
function parse_vatiants() {

    # Parse arguments
    local __parse_vatiants_string_="$1"
    local __parse_vatiants_parse_mode_="$2"
    local __parse_vatiants_variants_="$3"
    
    # Delimiter
    local delimiter="|"
    # Basic splitting method
    local method='split_and_trimm'

    # If raw parsing mode is requested, split without trimming
    if [[ "$__parse_vatiants_parse_mode_" == "raw" ]]; then
        method='split'
    fi

    # Perform command
    $method "$__parse_vatiants_string_" "$delimiter" "$__parse_vatiants_variants_"
}

# ---------------------------------------------------------------------------------------
# @brief Parses valid range associated with the argument
#
# @param string
#    string containing range
# @param parse_mode
#    parse mode (either 'default' - list element's will be trimmed - or 'raw' - list 
#    element's will NOT be trimmed)
# @param min [out]
#    name of the variable where the left limit of the range will be written
# @param mian [out]
#    name of the variable where the right limit of the range will be written
# ---------------------------------------------------------------------------------------
function parse_range() {

    # Parse arguments
    local    __parse_range_string_="$1"
    local    __parse_range_parse_mode_="$2"
    local -n __parse_range_min_="$3"
    local -n __parse_range_max_="$4"
    
    # Delimiter
    local delimiter=":"
    # Basic splitting method
    local method='split_and_trimm'
    # Result array
    local -a limits

    # If raw parsing mode is requested, split without trimming
    if [[ "$__parse_range_parse_mode_" == "raw" ]]; then
        method='split'
    fi

    # Perform splitting
    $method "$__parse_range_string_" "$delimiter" "limits"

    # Parse result in output variables
    __parse_range_min_="${limits[0]}"
    __parse_range_max_="${limits[1]}"
}
