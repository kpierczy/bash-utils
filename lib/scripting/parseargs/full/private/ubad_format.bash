#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ubad_format.sh
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 14th November 2021 2:24:35 pm
# @modified Friday, 18th February 2022 7:40:21 pm
# @project  bash-utils
# @brief
#    
#    List of functions related to parsing process of the UBAD table
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Function ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Checks whether @p string is a valid format of the positional argument
#
# @param string
#    string to be inspected
# @returns 
#    @c 0 if @p string is a valid argument's format
#    @c 1 otherwise
# ---------------------------------------------------------------------------------------
function is_ubad_positional_arg_format() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        ""                                           ) return 0 ;; # Empty identifier
        [[:alpha:]]*([[:alnum:]_])                   ) return 0 ;; # Single identifier (starts with an alphabetic character and consists of alphanums and underscored)
        [[:alpha:]]*([[:alnum:]_])\[*([[:digit:]])\] ) return 0 ;; # Single identifier (single identifier ended with '[n]' where n is number of subsequent positional arguments)
        [[:alpha:]]*([[:alnum:]_])\.\.\.             ) return 0 ;; # Single identifier (single identifier ended with '...')
        *                                            ) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether @p string is a valid format of the optional argument
#
# @param string
#    string to be inspected
# @returns 
#    @c 0 if @p string is a valid argument's format
#    @c 1 otherwise
# ---------------------------------------------------------------------------------------
function is_ubad_optional_arg_format() {

    # Arguments
    local string_="$1"

    # Limit modifications of the IFS word-splitter to the local scope
    localize_word_splitting
    
    # Set world-splitting-separator to ' ' + '|' automaticaly parse option's names
    IFS='|'
    # Set positional arguments to the option's names
    set -- $string_

    # A single format
    local format_

    # Iterate option's formats and check if they represent options
    for format_ in "$@"; do
        is_option "${format_}" || return 1
    done

    return 0
}

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
# @brief Checks whether given type refers to string argument
# ---------------------------------------------------------------------------------------
function is_ubad_arg_string() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        "string"  | "s" ) return 0 ;;
        *               ) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether given type refers to integer argument
# ---------------------------------------------------------------------------------------
function is_ubad_arg_integer() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        "integer"  | "i" ) return 0 ;;
        *                ) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether given type refers to flag argument
# ---------------------------------------------------------------------------------------
function is_ubad_arg_flag() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        "flag"  | "f" ) return 0 ;;
        *             ) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------------------
# @brief Checks whether given type refers to path argument
# ---------------------------------------------------------------------------------------
function is_ubad_arg_path() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        "path"  | "p" ) return 0 ;;
        *             ) return 1 ;;
    esac
}


# ---------------------------------------------------------------------------------------
# @brief Checks whether @p string is a valid integer
#
# @param string
#    string to be inspected
# @returns 
#    @c 0 if @p string is a valid integer \n
#    @c 1 otherwise
# ---------------------------------------------------------------------------------------
function is_ubad_integer() {

    # Arguments
    local string_="$1"

    # Prepare pattern
    local pattern_='^[+-]?[0-9]+$'

    # Match pattern
    [[ $string_ =~ $pattern_ ]] || return 1
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
# -------------------------------------------------------------------
function is_ubad_identifier() {

    # Arguments
    local string_="$1"

    # Check if the first character is valid (a letter or an underscore)
    [[ ${string_:0:1} =~ [[:alpha:]]|_ ]] || return 1

    # Iterate over the string's characters
    for ((i = 1; i < ${#string_}; i++)); do
        
        # Get the character
        local character_=${string_:$i:1}

        # Check if alphanumeric or underscore
        [[ $character_ =~ [[:alnum:]]|_ ]] ||
        # Else, return error
        return 1

    done

    # If no erronous character found, return success
    return 0
    
}


# ---------------------------------------------------------------------------------------
# @brief Turns type of the UBAD argument into it's stringified representation used in 
#    usage strings
#
# @param type
#    string to be transformed
# @outputs 
#    stringified name
# ---------------------------------------------------------------------------------------
function ubad_arg_type_usage_string() {

    # Arguments
    local string_="$1"

    # Check if valid type given
    case "${string_}" in
        "string"  | "s" ) echo "STR"  ;;
        "integer" | "i" ) echo "INT"  ;;
        "flag"    | "f" ) echo ""     ;;
        "path"    | "p" ) echo "PATH" ;;
        *               ) echo ""     ;;
    esac
}