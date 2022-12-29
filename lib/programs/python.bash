#!/usr/bin/env bash
# ====================================================================================================================================
# @file     python.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 9:59:27 pm
# @modified   Thursday, 29th December 2022 3:52:15 am
# @project  bash-utils
# @brief
#    
#    Set of functions managing python3 packages
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependencies
source $BASH_UTILS_HOME/lib/scripting/settings.bash
source $BASH_UTILS_HOME/lib/logging/logging.bash
source $BASH_UTILS_HOME/lib/scripting/parseargs/short/parseopts.bash

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @param package
#    name of the package to be exmained
# 
# @returns
#    @retval @c 0 if @p package is installed 
#    @retval @c 1 otherwise
# -------------------------------------------------------------------
function is_pip_package_installed() {
    
    # Arguments
    local package_="$1"
    
    # Check if installed
    python3 -m pip show "$package_" &> /dev/null && return 0 || return 1
    
}

# -------------------------------------------------------------------
# @brief Prints version of the installed PIP package to the stdout
# @param package
#    name of the package to be exmained
# 
# @returns
#    @retval @c 0 if @p package is installed and version was printed 
#    @retval @c 1 if @p package is not installed
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
# @brief Install @p packages using Python3 PIP module.
#
# @param packages
#    name of list holding names of packages to be installed
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 on error 
#
# @options
#    
#      -v   print verbose log
#    --vi   print verbose log if package is already installed
#      -U   use `-U` flag to install packages
#
# @environment
#
#    PIP_FLAGS  flags passed to the `pip install` command
#   
# -------------------------------------------------------------------
function pip_install_list() {

    # Arguments
    # local -n _packages_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v',verbose,f
        '--vi',verbose_installed,f
        '-U',upgrade,f
    )
    
    # Parse arguments to a named array
    parse_options_s

    # Parse arguments
    local -n _packages_="${posargs[0]}"

    # ----------------- Configure logs ----------------  
     
    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set options[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # ---------------- Prepare apt flags --------------   

    # Prepare installation mode (install/upgrade)
    local mode_flag_=''
    is_var_set options[upgrade] && 
        mode_flag_='--upgrade'

    # Prepare apt flags
    local pip_flags_="${PIP_FLAGS:-}"
    ! is_var_set options[verbose] && 
        pip_flags_+=' -q'
    
    # ----------------- Install packages --------------   

    local package_

    # Enable word-splitting to properly parse arguments
    localize_word_splitting
    enable_word_splitting

    # Iterate over packages
    for package_ in "${_packages_[@]}"; do

        # Parse package name (remove version requirement, if given)
        local package_name_="${package_%>*}"
        
        # If package not isntalled, install
        if ! is_pip_package_installed "$package_name_"; then

            # Log info, if verbose
            log_info "Installing $package_ ..."

            # Install package
            ! python3 -m pip install $pip_flags_ ${mode_flag_} "$package_" | \
                grep -v 'Requirement already satisfied'                    | \
                grep -v 'Requirement already up-to-date'

            # Install package
            if [[ ${PIPESTATUS[0]} == 0 ]]; then
                log_info "$package_ installed"
            else
                log_error "$package_ could not be installed"
                restore_log_config_from_default_stack
                return 1
            fi
            
        # If 'verbose installed' option passed, log info
        elif is_var_set options[verbose_installed]; then
            log_info "$package_ already installed"
        fi

    done

    # Restore logs status
    restore_log_config_from_default_stack

    return 0   
}

# -------------------------------------------------------------------
# @brief Install @p packages using Python3 PIP module.
#
# @param packages...
#    names of packages to be installed
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 on error 
#
# @options
#    
#      -v   print verbose log
#    --vi   print verbose log if package is already installed
#      -U   use `apt upgrade` to install packages
#
# @environment
#
#    PIP_FLAGS  flags passed to the `pip install` command
#   
# @note If PIP_FLAGS is set to '-r', the function may be used to
#    install packages from requirement file(s)
# -------------------------------------------------------------------
function pip_install() {

    # Arguments
    # local packages_...

    # ---------------- Parse arguments ----------------
    
    # Function's options
    declare -a opt_definitions=(
        '-v',verbose,f
        '--vi',verbose_installed,f
        '-U',upgrade,f
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
    pip_install_list "${options_list_[@]}" "packages_"
    
}

# -------------------------------------------------------------------
# @brief Adds @p path at the beginning of the PYTHONPATH variable if
#    is not alredy in PYTHONPATH
#
# @param path
#    path to be added to the PYTHONPATH
# -------------------------------------------------------------------
function prepend_python_path() {

    local path_="$1"

    # Prepend PATH
    is_substring "$PYTHONPATH" "$path_" || 
        PYTHONPATH="$path_:$PYTHONPATH"
        
}

# -------------------------------------------------------------------
# @brief Adds @p path at the end of the PYTHONPATH variable if is
#    not alredy in PATH
#
# @param path
#    path to be added to the PYTHONPATH
# -------------------------------------------------------------------
function append_python_path() {

    local path_="$1"

    # Prepend PYTHONPATH
    is_substring "$PYTHONPATH" "$path_" || 
        PYTHONPATH="$PYTHONPATH:$path_"
        
}
