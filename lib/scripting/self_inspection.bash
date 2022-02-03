#!/usr/bin/env bash
# ====================================================================================================================================
# @file     self_inspection.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:16:59 pm
# @modified Wednesday, 10th November 2021 7:08:44 pm
# @project  bash-utils
# @brief
#    
#    Set of general-use functions and aliases that can be exploited to inspect state of the calling script
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Writes absolute path to the calling script's home directory
#    to the stdout
# -------------------------------------------------------------------
function get_script_dir() {
    echo "$(dirname "$(readlink -f "${BASH_SOURCE[1]}")")"
}

# -------------------------------------------------------------------
# @brief Writes absolute path to the calling script's home directory
#    to the stdout (resolves symlinks)
# -------------------------------------------------------------------
function get_script_dir_sym() {

    # Get current source's path
    local src="${BASH_SOURCE[1]}"

    # Resolve source until the file is no longer a symlink
    while [[ -h "$src" ]]; do 
        # Resolve directory of the $stc
        local dir="$( cd -P "$( dirname "$src" )" >/dev/null 2>&1 && pwd )"
        # Readlink
        src="$(readlink "$src")"
        # If $src was a relative symlink, resolve it relative to the path where the symlink file was located
        [[ $src != /* ]] && SOURCE="$dir/$src" 
    done
    
    # Print result
    echo "$( cd -P "$( dirname "$src" )" >/dev/null 2>&1 && pwd )"

}

# -------------------------------------------------------------------
# @brief Check whether the calling script was executed by sourcing
# @param depth (optionl, default: 0)
#    if given, expresses depth of the call stack that should be
#    checked; e.g. by passing @c 1 the calling script can check 
#    whether the script that executed it was sourced.
#    This feature comes handy if one implements script's templates.
#    In such a case, the template script needs to return if it's
#    caller was sourced (assuming the script should be executed
#    only by running)
# 
# @returns 
#     @c 0 if calling script was sourced \n
#     @c 1 otherwise
# -------------------------------------------------------------------
function is_sourced() {

    # Arguments
    local -i depth=${1:-0};

    # Check if a valid depth was given
    if (( ${#FUNCNAME} == $depth + 1 )); then
        return 0
    fi

    # Check if script was sourced
    [[ ${FUNCNAME[$depth + 1]} == source ]]
}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Writes home directory of the calling script to the local 
#     DIR variable 
#
# @param DIR (out, global)
#     set to the home directory of the calling script
# -------------------------------------------------------------------
alias set_script_dir='declare DIR="$(dirname "$(readlink -f "$BASH_SOURCE")")"'

# -------------------------------------------------------------------
# @brief Calls 'return' if script was sourced
# -------------------------------------------------------------------
alias return_if_sourced='is_sourced && return'
