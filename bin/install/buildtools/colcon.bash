#!/usr/bin/env bash
# ====================================================================================================================================
# @file     colcon.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 14th February 2022 3:08:56 pm
# @modified   Thursday, 12th May 2022 9:47:26 pm
# @project  bash-utils
# @brief
#    
#    Installation script for the colcon
#    
# @source
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs colcon build system"

# ============================================================ Constants =========================================================== #

# Logging context of the script
declare LOG_CONTEXT="colcon"

# ========================================================== Configruation ========================================================= #

# URL of the apt identification key
declare APT_KEY_URL='https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc'

# ============================================================== Main ============================================================== #

function install() {

    # Check if package is already installed
    if ! is_pkg_installed python3-colcon-common-extensions; then

        log_info "Adding colcon repository to apt..."

        # Repo string to be palced in apt sources
        local APT_REPO_STRING="deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main $(lsb_release -cs) main"
        # Repo file for APT
        local APT_REPO_FILE="/etc/apt/sources.list.d/ros2-latest.list"

        # Add colcon repository
        curl -s "$APT_KEY_URL" | gpg --dearmor | sudo tee "/etc/apt/trusted.gpg.d/ros.gpg" > /dev/null
        # Write content to the file
        echo "$APT_REPO_STRING" | sudo tee "$APT_REPO_FILE" > /dev/null

        log_info "Installing colcon..."

        # Install colcon
        sudo apt update && install_pkg --su -y python3-colcon-common-extensions || {
            log_error "Failed to install package 'python3-colcon-common-extensions'"
            return 1
        }
        
        # Install additional package
        sudo apt update && install_pkg --su -y python3-colcon-mixin || {
            log_error "Failed to install package 'python3-colcon-mixin'"
            return 1
        }

        log_info "Package installed"

    fi

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/simple_install.bash
