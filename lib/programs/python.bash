#!/usr/bin/env bash
# ====================================================================================================================================
# @file     python.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 9:59:27 pm
# @modified Wednesday, 10th November 2021 6:39:25 pm
# @project  BashUtils
# @brief
#    
#    Set of functions managing python3 packages
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @param package
#    name of the package to be exmained
# 
# @returns
#    @c 0 if @p package is installed \n
#    @c 1 otherwise
# -------------------------------------------------------------------
function is_pip_package_installed() {
    
    # Arguments
    local package_="$1"
    
    # Check if installed
    python3 -m pip list | grep "$package_" > /dev/null
}

# -------------------------------------------------------------------
# @brief Prints version of the installed PIP package to the stdout
# @param package
#    name of the package to be exmained
# 
# @returns
#    @c 0 if @p package is installed and version was printed \n
#    @c 1 if @p package is not installed
# -------------------------------------------------------------------
function get_pip_package_version() {
    
    # Arguments
    local package_="$1"
    
    # Check if installed
    local package_spec_="$(python3 -m pip list | grep "$package_")" || return
    
    # Parse and print package's specification
    echo $(echo "$package_spec_" | awk '{print $2}')
    
}

# -------------------------------------------------------------------
# @brief Install @p entity using Python3 PIP module. Trims log 
#    output so that the resulting string contains only informations
#    concerning packages that was actually installed in the process.
#    'Already installed' and 'Already up-to-date' messages are
#    discarded.
#
# @param entity
#    name of the entity (e.g. package, requirements file) to be 
#    installed
#
# @returns 
#    status of the pip command
#
# @environment
#
#    PIP_FLAGS  flags passed to the `pip install` command
#   
# -------------------------------------------------------------------
function pip_install() {

    # Arguments
    local package_="$1"

    # Install package
    echo "python3 -m pip install "${PIP_FLAGS:-}" "$package_""
    ! python3 -m pip install "${PIP_FLAGS:-}" "$package_" | \
        grep -v 'Requirement already satisfied'           | \
        grep -v 'Requirement already up-to-date'

    # Return PIP's status
    return ${PIPESTATUS[0]}
    
}
