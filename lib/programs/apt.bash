#!/usr/bin/env bash
# ====================================================================================================================================
# @file     packages.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:16:59 pm
# @modified   Thursday, 12th May 2022 10:09:56 pm
# @project  bash-utils
# @brief
#    
#    Set of functions performing basic routines related to apt packages
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependencies
source $BASH_UTILS_HOME/lib/scripting/settings.bash
source $BASH_UTILS_HOME/lib/logging/logging.bash

# ====================================================== Inspection functions ====================================================== #

# -------------------------------------------------------------------
# @brief Prints a list of current apt sources to te stdout
# -------------------------------------------------------------------
function get_apt_soruces() {
    find /etc/apt/ -name *.list | xargs cat | grep  "^[[:space:]]*deb[-src]*"
}

# -------------------------------------------------------------------
# @brief Prints a list of current binary apt sources to te stdout
# -------------------------------------------------------------------
function get_apt_bin_soruces() {
    find /etc/apt/ -name *.list | xargs cat | grep  "^[[:space:]]*deb"
}

# -------------------------------------------------------------------
# @brief Prints a list of current src apt sources to te stdout
# -------------------------------------------------------------------
function get_apt_src_soruces() {
    find /etc/apt/ -name *.list | xargs cat | grep  "^[[:space:]]*deb-src"
}


# -------------------------------------------------------------------
# @param package 
#    name of the apt package
# @returns 
#     @c 0 if apt package is installed \n
#     @c 1 otherwise
# -------------------------------------------------------------------
function is_pkg_installed() {

    # Arguments
    local package_=$1

    # Check if installed
    $(dpkg -s $package_ &> /dev/null)
}

# ======================================================= Modifying functions ====================================================== #

# ---------------------------------------------------------------------------------------
# @brief Installs packages listed on the @p packages list using apt
#
# @param packages
#    name of the list holding names of packages to be installed
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 on error 
#
# @options
#    
#                   --su  installs packages as super user
#                     -y  installs packages in non-interactive mode
#                     -v  print verbose log
#                   --vi  print verbose log if package is already installed
#                     -U  use `apt upgrade` to install packages
#  -a, --allow-local-app  if set, before checking whether the package is installed, the
#                         function will check whether the appllication with the given
#                         name and if so, it will skip installation
#   -f, --allow-failures  when one of packages cannot be installed, only error will be 
#                         printed and installation of further packages in the list will
#                         proceed
# 
# @environment
#  
#     APT_FLAGS  Additional flags that will be prepended to the apt
#                flags set by the function
# 
# ---------------------------------------------------------------------------------------
function install_pkg_list() {
    
    # Arguments
    # local -n _packages_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '--su',superuser,f
        '-v',verbose,f
        '--vi',verbose_installed,f
        '-y',non_interactive,f
        '-U',upgrade,f
        '-a|--allow-local-app',allow_local,f
        '-f|--allow-failures',allow_failures,f
    )
    
    # Parse arguments to a named array
    parse_options_s
    
    # Parse arguments
    local -n _packages_="${posargs[0]}"

    # ------------ Configure word-splitting -----------   

    # Make changes to the word-splitting local
    localize_word_splitting
    # Enable default woprd splitting
    enable_word_splitting

    # ----------------- Configure logs ----------------   
    
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)
    
    # Enable/disable logs depending on the configuration
    is_var_set options[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # ---------------- Prepare apt flags --------------   

    # Check if sudo should be used
    local user_mode_=''
    is_var_set options[superuser] && 
        user_mode_='sudo'

    # Prepare apt command
    local apt_cmd_='install'
    is_var_set options[upgrade] && 
        apt_cmd_='upgrade'

    # Prepare apt flags
    local apt_flags_="${APT_FLAGS:-}"
    is_var_set options[non_interactive] &&
        apt_flags_+='-y '
    ! is_var_set options[verbose] && 
        apt_flags_+='-q '
    
    # ----------------- Install packages --------------   

    local package_

    # Iterate over packages
    for package_ in "${_packages_[@]}"; do
        
        # Check if application named 'package_' is accessible from the local context
        if is_var_set_non_empty options[allow_local] && is_app_installed "$package_"  ; then
            local skip_install_=1
        else
            local skip_install_=0
        fi

        # If package not installed, install
        if [[ ${skip_install_} == 0 ]] && ! is_pkg_installed $package_ ; then

            log_info "Installing $package_ ..."
            
            # Install package
            if ${user_mode_} apt ${apt_cmd_} ${apt_flags_} "$package_"; then
                log_info "$package_ installed"
            else

                # Print error
                log_error "$package_ could not be installed"
                # Return from fucntion, if error supressing has not been requested
                if ! is_var_set options[allow_failures]; then
                    restore_log_config_from_default_stack
                    return 1
                fi
            fi
            
        # If 'verbose installed' option passed, log info
        elif is_var_set options[verbose_installed]; then
            log_info "$package_ already installed"
        fi

    done

    # Restore logs status
    restore_log_config_from_default_stack

}

# -------------------------------------------------------------------
# @brief Installs @p packages using apt
#
# @param package...
#    packages to be installed
#
# @options
#    
#    --su   installs packages as super user
#      -y   installs packages in non-interactive mode
#      -v   print verbose log
#    --vi   print verbose log if package is already installed
#      -U   use `apt upgrade` to install packages
#  -a, --allow-local-app  if set, before checking whether the package is installed, the
#                         function will check whether the appllication with the given
#                         name and if so, it will skip installation
#   -f, --allow-failures  when one of packages cannot be installed, only error will be 
#                         printed and installation of further packages in the list will
#                         proceed
#
# @environment
#  
#     APT_FLAGS  Additional flags that will be prepended to the apt
#                flags set by the function
# 
# -------------------------------------------------------------------
function install_pkg() {

    # Arguments
    # local packages_...

    # ---------------- Parse arguments ----------------
    
    # Function's options
    declare -a opt_definitions=(
        '--su',superuser,f
        '-v',verbose,f
        '--vi',verbose_installed,f
        '-y',non_interactive,f
        '-U',upgrade,f
        '-a|--allow-local-app',allow_local,f
        '-f|--allow-failures',allow_failures,f
    )

    # Parse arguments
    parse_options_s
    
    # Parse packages to be installed into an array
    local -a packages_=( "${posargs[@]}" )

    # -------- Call underlying implementation ---------

    declare -a options_list_

    # Remove all positional arguments from the initial list
    substract_arrays args packages_ options_list_

    # Call implementation 
    install_pkg_list "${options_list_[@]}" packages_

}
