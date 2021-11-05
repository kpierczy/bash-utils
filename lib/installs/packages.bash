#!/usr/bin/env bash
# ====================================================================================================================================
# @file     packages.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:16:59 pm
# @modified Friday, 5th November 2021 1:52:25 am
# @project  BashUtils
# @brief
#    
#    Set of functions performing basic routines related to software packages
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source logging helper
source $BASH_UTILS_HOME/lib/logging/logging.bash
# Source general scripting helpers
source $BASH_UTILS_HOME/lib/scripting/general.bash
# Source general variables helpers
source $BASH_UTILS_HOME/lib/scripting/variables.bash

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @param package 
#    name of the apt package
# @returns 
#     @c 0 if apt package is installed \n
#     @c 1 otherwise
# -------------------------------------------------------------------
is_pkg_installed() {

    # Arguments
    local package=$1

    # Check if installed
    $(dpkg -s $package &> /dev/null)
}

# -------------------------------------------------------------------
# @brief Installs @p package list using apt
#
# @param package
#    package to be installed
#
# @options
#    
#    --su   installs packages as super user
#    -y     installs packages in non-interactive mode
#    -v     print verbose log
#    --vi   print verbose log if package is already installed
#
# -------------------------------------------------------------------
install_pkg() {

    # Function's options
    declare -a defs=(
        '--su',superuser,f
        '-v',verbose,f
        '--vi',verbose_installed,f
        '-y',non_interactive,f
    )

    # Enable words-splitting locally
    local IFS
    enable_word_splitting

    # Parse options
    local -A options
    parseopts "$*" defs options posargs
    
    # Arguments
    local package_=$posargs
    
    # Prepare apt context
    local su_command=''
    is_var_set options[superuser] && su_command+='sudo'
    # Prepare apt flags
    local apt_flags=''
    is_var_set options[non_interactive] && apt_flags+='-y '
    ! is_var_set options[verbose]       && apt_flags+='-q '
    
    # If package not isntalled, install
    if ! is_pkg_installed $package_; then

        # Log info, if verbose
        is_var_set options[verbose] && log_info "Installing $package_ ..."
        # Install package
        ${su_command} apt install ${apt_flags} $package_
        # If package could not be installed, return error
        if $?; then
            is_var_set options[verbose] && log_info "$package_ installed"
        else
            is_var_set options[verbose] && log_error "$package_ could not be installed"
            return 1
        fi
        
    # If 'verbose installed' option passed, log info
    elif is_var_set options[verbose_installed]; then
        log_info "$package_ already installed"
    fi

}

# -------------------------------------------------------------------
# @brief Installs @p packages list using apt
#
# @param packages
#    name of the list holding names of packages to be installed
#
# @options
#    
#    --su   installs packages as super user
#    -y     installs packages in non-interactive mode
#    -v     print verbose log
#    --vi   print verbose log if package is already installed
#    -U     use `apt upgrade` to isntall packages
#
# -------------------------------------------------------------------
install_packages() {
    
    # Function's options
    local -a defs=(
        '--su',superuser,f
        '-v',verbose,f
        '--vi',verbose_installed,f
        '-y',non_interactive,f
        '-U',upgrade,f
    )

    # Enable words-splitting locally
    local IFS
    enable_word_splitting
    
    # Parse options
    local -A options
    parseopts "$*" defs options posargs

    # Arguments
    local -n packages_=$posargs
    local package
    
    # Prepare apt context
    local su_command=''
    is_var_set options[superuser] && su_command+='sudo'
    # Prepare apt command
    local apt_cmd='install'
    is_var_set options[upgrade] && local apt_cmd='upgrade'
    # Prepare apt flags
    local apt_flags=''
    is_var_set options[non_interactive] && apt_flags+='-y '
    ! is_var_set options[verbose]       && apt_flags+='-q '
    
    # Iterate over packages
    for package in "${packages_[@]}"; do
        
        # If package not isntalled, install
        if ! is_pkg_installed $package; then

            # Log info, if verbose
            is_var_set options[verbose] && log_info "Installing $package ..."
            # Install package
            if ${su_command} apt ${apt_cmd} ${apt_flags} $package; then
                is_var_set options[verbose] && log_info "$package installed"
            else
                echo "Goodbye"
                is_var_set options[verbose] && log_error "$package could not be installed"
                return 1
            fi
            
        # If 'verbose installed' option passed, log info
        elif is_var_set options[verbose_installed]; then
            log_info "$package already installed"
        fi
    done

}
