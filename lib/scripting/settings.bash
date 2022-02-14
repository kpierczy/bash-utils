#!/usr/bin/env bash
# ====================================================================================================================================
# @file     settings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:19:43 am
# @modified Monday, 14th February 2022 8:15:00 pm
# @project  bash-utils
# @brief
#    
#    Handy functions aimed to configure script's environment
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Enables/disables macros' expansion
#
# @param query
#    if @c 'on', aliases expansion will be enabled \n
#    if @c 'off', aliases expansion will be disabled
# -------------------------------------------------------------------
function set_aliases_expansion() {

    # Arguments
    local query_="$1"

    # Set aliases expansion
    case $query_ in
        on  ) shopt -s expand_aliases;;
        off ) shopt -u expand_aliases;;
    esac
    
}

# -------------------------------------------------------------------
# @brief Disables default bash-word splitting by setting @glob IFS
#   variable to '' (an empty string). In result (in most cases) 
#   quotation mark  around evaluation expressions (like "$params") 
#   can be ommittes without separating content of the expression
#   based on the spaces.
# -------------------------------------------------------------------
function disable_word_splitting() {
    IFS=''
}

# -------------------------------------------------------------------
# @brief Enables default bash-word splitting by setting @glob IFS
#   variable to ' ' (a space). 
# -------------------------------------------------------------------
function enable_word_splitting() {
    IFS=$' \t\n'
}

# -------------------------------------------------------------------
# @brief Sets record bash-word splitting by setting @glob IFS
#   variable to \037 (ASCII unit separator)
#
# @note In this separation mode arrays can be passed to functions
#    like this:
#
#   myfunc () {
#   
#       # Parse array arguments
#       local myarray1=( $1 )
#       local myarray2=( $2 )
#   
#       [...]
#   }
#   
#   # Enable record-based split
#   set_word_splitting_record
#
#   # Declar some arrays
#   argument1=( "a value1" "another value1" )
#   argument2=( "a value2" "another value2" )
#   
#   # Call function with array arguments
#   myfunc "${argument1[*]}" "${argument2[*]}"
#
# @note In Bash >= 4.3 the cleaner way is to pass array's name to
#    the function and make t a reference with 'local -n ref=$1'
# -------------------------------------------------------------------
function set_word_splitting_record() {
    IFS=$'\037'
}

# -------------------------------------------------------------------
# @brief Enables globbing
# -------------------------------------------------------------------
function enable_globbing() {
    shopt -s extglob
}

# -------------------------------------------------------------------
# @brief Disables globbing
# -------------------------------------------------------------------
function disable_globbing() {
    shopt -u extglob
}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Limits changes to the word-splitting settings (@var IFS)
#    to the current function
# -------------------------------------------------------------------
alias localize_word_splitting='local IFS=$IFS'

# -------------------------------------------------------------------
# @brief Limits changes to the bash options by defining '-' as local
# -------------------------------------------------------------------
alias localize_bash_options='local -'
