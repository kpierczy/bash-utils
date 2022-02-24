#!/usr/bin/env bash
# ====================================================================================================================================
# @file     settings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:19:43 am
# @modified Wednesday, 23rd February 2022 8:20:13 pm
# @project  bash-utils
# @brief
#    
#    Handy functions aimed to configure script's environment
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @outputs shell options
# -------------------------------------------------------------------
function get_shell_options() {
    echo $-
}

# -------------------------------------------------------------------
# @brief Converts shell option to the short one
#
# @param option
#    option string to be converted
# @returns
#   @retval @c 0 on success
#   @retval @c 1 on failure
# -------------------------------------------------------------------
function shell_options_to_short() {

    # Arguments
    local option="$1"

    # If long option given, associate it with a letter
    if [[ "${#option}" != "1" ]]; then
        case "$option" in
            'allexport'   | 'a' ) echo 'a' ;;
            'braceexpand' | 'B' ) echo 'B' ;;
            'errexit'     | 'e' ) echo 'e' ;;
            'errtrace'    | 'E' ) echo 'E' ;;
            'functrace'   | 'T' ) echo 'T' ;;
            'hashall'     | 'h' ) echo 'h' ;;
            'histexpand'  | 'H' ) echo 'H' ;;
            'keyword'     | 'k' ) echo 'k' ;;
            'monitor'     | 'm' ) echo 'm' ;;
            'noclobber'   | 'C' ) echo 'C' ;;
            'noexec'      | 'n' ) echo 'n' ;;
            'noglob'      | 'f' ) echo 'f' ;;
            'notify'      | 'b' ) echo 'b' ;;
            'nounset'     | 'u' ) echo 'u' ;;
            'onecmd'      | 't' ) echo 't' ;;
            'physical'    | 'P' ) echo 'P' ;;
            'privileged'  | 'p' ) echo 'p' ;;
            'verbose'     | 'v' ) echo 'v' ;;
            'xtrace'      | 'x' ) echo 'x' ;;
            * )
                return 1
        esac
    fi

    return 0
}



# -------------------------------------------------------------------
# @brief Check whether shell option is set
#
# @param option
#    letter associated with the option
# @returns
#   @retval @c 0 if @p option is set
#   @retval @c 1 otherwise
# -------------------------------------------------------------------
function is_shell_option_set() {

    # Arguments
    local option="$1"

    # If long option given, associate it with a letter
    option=$(shell_options_to_short "$option") || return 1

    # Check if option set
    [[ "$-" == *$option* ]]
}

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
