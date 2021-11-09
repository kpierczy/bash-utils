#!/usr/bin/env bash
# ====================================================================================================================================
# @file     modifying.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:04:36 am
# @modified Tuesday, 9th November 2021 3:16:25 am
# @project  BashUtils
# @brief
#    
#    Set of handy functions related to files' manipulation
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependency
source $BASH_UTILS_HOME/lib/scripting/settings.bash

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Writes number of lines of the @p file to the stdout
#
# @param file
#    path to the file to be read
#
# @returns 
#     @c 0 on success \n
#     @c 1 if @p file does not exists
# -------------------------------------------------------------------
function get_file_lines_num() {

    # Arguments
    local file_="$1"

    # Check if the file exists
    [[ -f "$file_" ]] || return 1

    # Print line
    wc -l "$file_" | awk '{ print $1 }'
}

# -------------------------------------------------------------------
# @brief Writes @p n'th line of the @p file to the stdout
#
# @param file
#    path to the file to be read
# @param line
#    index of the line to be read (starting from 1)
#
# @returns 
#     @c 0 on success \n
#     @c 1 if @p file does not exists or it contains fewer
#        lines than @p line
# -------------------------------------------------------------------
function get_file_line() {

    # Arguments
    local file_="$1"
    local line_="$2"

    # Check if the file exists
    [[ -f "$file_" ]] || return 1

    # Read how many lines has the file
    local lines_num=$(get_file_lines_num "$file_")
    # Check if file has enough lines
    (( $lines_num >= $line_ )) || return 1

    # Print line
    sed "${line_}q;d" "$file_"
}

# -------------------------------------------------------------------
# @brief Writes @p lines to the stdout
#
# @param lines...
#    lines to be printed
# -------------------------------------------------------------------
function print_lines() {

    for line_ in "$@"; do
        echo "$line_"
    done
    
}

# -------------------------------------------------------------------
# @brief Prints extension of the @p filename (substring of the 
#   @p filename placed after the last '.') to the stdout
#
# @param filename
#    name of the file to be processed
# @returns
#    @c 0 on success \n
#    @c 1 if @p filename without extension was given
# -------------------------------------------------------------------
function get_file_extension() {
    
    # Arguments
    local _filename_=$1

    # Get file's extension
    local _extension_=${1##*.}

    # Check if @p filename contains an extension
    if [[ "$_filename_" != "$_extension_" ]]; then
        echo "$_extension_"
    else
        return 1
    fi

}

# -------------------------------------------------------------------
# @brief Prints to the stdout @p filename with an extension 
#   (the substring starting from the last '.') removed. By default,
#   if @p filename without an extension is given, function rewrites
#   it to the stdout despite returning an error status
#
# @param filename
#    name of the file to be processed
# @returns
#    @c 0 on success \n
#    @c 1 if @p filename without extension was given
#
# @options
#
#    -z if @p filename without extension is given, function
#       returns an empty string
#
# -------------------------------------------------------------------
remove_file_extension() {
    
    # Arguments
    local _filename_

    # Options
    local defs=(
        '-z',empty,f
    )

    # Disable word splitting in the context of the function
    limit_word_splitting_settings
    disable_word_splitting

    # Parsed options
    local -a args=( "$@" )
    local -A options

    # Parse options
    parseopts args defs options posargs || return 1

    # Set positional arguments
    set -- ${posargs[@]}

    # Parse arguments
    _filename_="$1"

    # Local variables
    local _extension_
    
    # Get file's extension
    _extension_="$(get_file_extension "$_filename_")" || {
        is_var_set options[empty] || echo "$_filename_"
        return 1
    }

    # Print @p filename with extension suffix removed
    echo "${_filename_%."$_extension_"}"

}
