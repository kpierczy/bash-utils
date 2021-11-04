#!/usr/bin/env bash
# ====================================================================================================================================
# @file     self_inspection.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:16:59 pm
# @modified Thursday, 4th November 2021 12:55:01 am
# @project  BashUtils
# @brief
#    
#    Set of general-use functions and aliases that can be exploited to inspect state of the calling script
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Writes home directory of the calling script to the local 
#     DIR variable 
#
# @param DIR (out, global)
#     set to the home directory of the calling script
# -------------------------------------------------------------------
alias set_script_dir='declare DIR="$(dirname "$(readlink -f "$BASH_SOURCE")")"'

# -------------------------------------------------------------------
# @brief Writes absolute path to the calling script's home directory
#    to the stdout
# -------------------------------------------------------------------
get_script_dir() {
    echo "$(dirname "$(readlink -f "${BASH_SOURCE[1]}")")"
}

# -------------------------------------------------------------------
# @brief Writes absolute path to the calling script's home directory
#    to the stdout (resolves symlinks)
# -------------------------------------------------------------------
get_script_dir_sym() {

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
# @returns 
#     @c 0 if calling script was sourced \n
#     @c 1 otherwise
# -------------------------------------------------------------------
is_sourced() {
    [[ ${FUNCNAME[1]} == source ]]
}

# -------------------------------------------------------------------
# @brief Calls 'return' if script was sourced
# -------------------------------------------------------------------
alias return_if_sourced='is_sourced && return'
