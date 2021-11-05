#!/usr/bin/env bash
# ====================================================================================================================================
# @file     python.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 9:59:27 pm
# @modified Friday, 5th November 2021 12:53:06 am
# @project  BashUtils
# @brief
#    
#    Set of functions managing python3 packages
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ========================================================= Implementations ======================================================== #


# -------------------------------------------------------------------
# @brief Trims stdin input from  lines containing messages 
#    charcteristic for info logs output by the PIP package manager
#    informing user about already met requirements
# -------------------------------------------------------------------
_pip_trim_log_output() {
    ! grep -v 'Requirement already satisfied' | grep -v 'Requirement already up-to-date'
}

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @param package
#    name of the package to be exmained
# 
# @returns
#    @c 0 if @p package is installed \n
#    @c 1 otherwise
# -------------------------------------------------------------------
is_pip_package_installed() {
    
    # Arguments
    local package=$1
    
    # Check if installed
    python3 -m pip list | grep "$package" > /dev/null
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
get_pip_package_version() {
    
    # Arguments
    local package=$1
    
    # Check if installed
    package_spec="$(python3 -m pip list | grep "$package")" || return
    
    # Parse and print package's specification
    echo $(echo "$package_spec" | awk '{print $2}')
    
}

# -------------------------------------------------------------------
# @brief Install @p package using Python3 PIP module trimming it's 
#    output The result print only informations concerning packages 
#    that was actually installed in the process. 'Already installed' 
#    and 'Already up-to-date' messages are discarded.
#
# @param package
#    name of the package to be installed
# -------------------------------------------------------------------
pip_install_package() {

    # Arguments
    local package=$1

    # Install package
    ! python3 -m pip install $package | _pip_trim_log_output

    return
}

# -------------------------------------------------------------------
# @brief Upgrades @p package using Python3 PIP module trimming it's 
#    output The result print only informations concerning packages 
#    that was actually installed in the process. 'Already installed' 
#    and 'Already up-to-date' messages are discarded.
#
# @param package
#    name of the package to be upgraded
# -------------------------------------------------------------------
pip_install_upgrade_package() {

    # Arguments
    local package=$1
    
    # Upgrade package
    ! python3 -m pip install -U $package | _pip_trim_log_output
 
    return 0
}

# -------------------------------------------------------------------
# @brief Upgrades @p requirements using Python3 PIP module trimming 
#    it's output The result print only informations concerning 
#    packages that was actually installed in the process. 'Already 
#    installed' and 'Already up-to-date' messages are discarded.
#
# @param requirements
#    path to the file containing list of requirements
# -------------------------------------------------------------------
pip_install_requirements() {

    # Arguments
    local requirements=$1

    # Upgrade package
    ! python3 -m pip install -r $requirements | _pip_trim_log_output

    return
}
