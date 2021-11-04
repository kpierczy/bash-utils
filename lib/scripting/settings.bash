#!/usr/bin/env bash
# ====================================================================================================================================
# @file     settings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:19:43 am
# @modified Thursday, 4th November 2021 12:04:11 am
# @project  BashUtils
# @brief
#    
#    Handy functions aimed to configure script's environment
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Enables/disables macros' expansion
#
# @param query
#    if @c 'on', aliases expansion will be enabled \n
#    if @c 'off', aliases expansion will be disabled
# -------------------------------------------------------------------
set_aliases_expansion() {

    local query=$1

    case $query in
        on )  shopt -s expand_aliases;;
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
disale_word_splitting() {
    IFS=''
}

# -------------------------------------------------------------------
# @brief Enables default bash-word splitting by setting @glob IFS
#   variable to ' ' (a space). 
# -------------------------------------------------------------------
enable_word_splitting() {
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
set_word_splitting_record() {
    IFS=$'\037'
}
