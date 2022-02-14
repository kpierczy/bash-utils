#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 4:50:15 pm
# @modified Monday, 14th February 2022 7:33:06 pm
# @project  bash-utils
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
    (( ${#string_} >= ${#prefix_} )) || return 1

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

# -------------------------------------------------------------------
# @brief Transforms a numeral value @p value into it's conjugated
#    aby appending an appropriate ending. Prints result to the 
#    stdout
# 
# @param value
#    string to be conjugated
#
# @returns 
#    @c 0 on success \n
#    @c 1 if a non-numerical @p value given
# -------------------------------------------------------------------
function inflect_numeral() {

    # Arguments
    local value_="$1"

    local units_

    # Try to get units from the value
    units_=$(( $value_ % 10 )) || return 1

    # Numerator's conjugation
    case $units_ in
        1 ) echo "${value_}st";;
        2 ) echo "${value_}nd";;
        3 ) echo "${value_}rd";;
        * ) echo "${value_}th";;
    esac

    return 0
}

# -------------------------------------------------------------------
# @brief Writes length of the @p string to the stdout
# 
# @param string
#    string to be evaluated
# -------------------------------------------------------------------
function strlen() {

    # Arguments
    local string_="$1"

    # Write length to the stdout
    echo "${#string_}"
    
}

# -------------------------------------------------------------------
# @brief Checks whether the @p string is a valid identifier, i.e.
#    if it is composed of alphanumeric symbols and underscores with
#    non-numerical first character
# 
# @param string
#    string to be evaluated
#
# @returns 
#    @c 0 if @p string is a valid identifier \n
#    @c 1 otherwise
#
# @options
#
#   -e|--extend--charset=STR  String containing additional characters 
#                             that may occur in the @p string to be 
#                             qualified as a valid identifier; 
#                             doesn't;
#   -a|--allow-non-std-front  if set, the leading character of the
#                             @p string may be non-letter and 
#                             non-underscore character from the 
#                             allowed charset
#   -n|--no-numbers           if set no numbers are allowed in the 
#                             name 
#
# -------------------------------------------------------------------
function is_identifier() {

    # Arguments
    local string_="$1"

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-e|--charset',charset
        '-a|--allow-non-std-front',non_std_start,f
        '-n|--no-numbers',no_numbers,f
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    string_="${posargs[0]}"

    # Parse options
    local extended_charset_="${options[charset]:-}"
    local non_std_start_="${options[non_std_start]:-}"
    local no_numbers="${options[no_numbers]:-}"

    # ------------------------------------------------- 

    local -a extended_charset_list_=()

    # Extend charset, if requested
    is_var_set_non_empty extended_charset_ &&
    for ((i = 0; i < ${#extended_charset_}; i++)); do
        extended_charset_list_+=( ${extended_charset_:$i:1} )
    done

    # Check if non-empty string given
    [[ -n ${#string_} ]] || return 1

    # Check if the extended leading character was requested
    if is_var_set_non_empty non_std_start_; then

        local first_invalid_=1

        # Check first character is a letter or an underscore
        if [[ ${string_:0:1} =~ [[:alpha:]]|_ ]]; then
            first_invalid_=0
        # Check first character is one of characters from the extended charset
        elif is_var_set_non_empty non_std_start_; then
            # Iterate over the extended charset
            for ((i = 0; i < ${#extended_charset_}; i++)); do
                # Compare the dirst character with the character from the carset
                [[ ${string_:0:1} == ${extended_charset_:$i:1} ]] && {
                    first_invalid_=0
                    break
                }
            done
        fi

        # If no valid character was found, return error
        [[ $first_invalid_ == "0" ]] || return 1

    # If no extended leading character was requested
    else

        # Check if the first character is valid (a letter or an underscore)
        [[ ${string_:0:1} =~ [[:alpha:]]|_ ]] || return 1

    fi

    # Iterate over the string's characters
    for ((i = 1; i < ${#string_}; i++)); do
        
        # Get the character
        local character_=${string_:$i:1}

        # Check if alphabetic/alphanumeric or underscore
        is_var_set_non_empty no_numbers && 
            [[ $character_ =~ [[:alpha:]]|_ ]] ||
        ! is_var_set_non_empty no_numbers && 
            [[ $character_ =~ [[:alnum:]]|_ ]] ||
        # Check if one of extended characters
        is_array_element extended_charset_list_ $character_ ||
        # Else, return error
        return 1

    done

    # If no erronous character found, return success
    return 0
    
}

# -------------------------------------------------------------------
# @brief Checks whether the @p string represents a number
# 
# @param string
#    string to be evaluated
#
# @options
#
#   -u|--unsigned If set, function matches only numbers without 
#                 a leading sign
# @returns 
#    @retval @c 0 if @p string represents a number
#    @retval @c 1 otherwise
# -------------------------------------------------------------------
function represents_number() {
    
    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-u|--unsigned',unsigned,f
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    local string_="${posargs[0]}"

    # Parse options
    local unsigned="${options[unsigned]:-}"
    
    # ------------------------------------------------- 

    local pattern_=''

    # Select pattern
    if is_var_set_non_empty unsigned; then
        pattern_='^[0-9]+([.][0-9]+)?$'
    else
        pattern_='^[+-]?[0-9]+([.][0-9]+)?$'
    fi

    # Match pattern
    [[ $string_ =~ $pattern_ ]] || return 1
}

# -------------------------------------------------------------------
# @brief Checks whether the @p string represents an integer
# 
# @param string
#    string to be evaluated
#
# @options
#
#   -u|--unsigned If set, function matches only numbers without 
#                 a leading sign
#
# @returns 
#    @retval @c 0 if @p string represents a number
#    @retval @c 1 otherwise
# -------------------------------------------------------------------
function represents_integer() {
    
    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-u|--unsigned',unsigned,f
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    local string_="${posargs[0]}"

    # Parse options
    local unsigned="${options[unsigned]:-}"

    # ------------------------------------------------- 

    local pattern_=''

    # Select pattern
    if is_var_set_non_empty unsigned; then
        pattern_='^[0-9]+$'
    else
        pattern_='^[+-]?[0-9]+$'
    fi

    # Match pattern
    [[ $string_ =~ $pattern_ ]] || return 1
}

# -------------------------------------------------------------------
# @brief Checks whether @p string is any of @p ...
# 
# @param string
#    string to be evaluated
# @param ...
#    list of strings to be compared against
#
# @returns 
#    @c 0 if @p string is equal to any of @p ...
#    @c 1 otherwise
# -------------------------------------------------------------------
function is_any_of() {

    # Arguments
    local string_="$1"
    local -a elements_=("${@:2}")
    # Local variables
    local e_
    
    # Check array
    for e_ in "${elements_[@]}"; do
        [[ "$e_" == "$string_" ]] && return 0
    done

    return 1
}
