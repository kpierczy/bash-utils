#!/usr/bin/env bash
# ====================================================================================================================================
# @file     colcon.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 14th February 2022 3:08:56 pm
# @modified Wednesday, 23rd February 2022 1:32:41 am
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

        # Add colcon repository
        log_info "Adding repository"
        curl -s "$APT_KEY_URL" | sudo apt-key add -
        sudo sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

        # Install colcon
        sudo apt update && install_pkg --su -y python3-colcon-common-extensions
        # Install additional package
        sudo apt update && install_pkg --su -y python3-colcon-mixin

    fi

}

# ============================================================== Main ============================================================== #

function main() {

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi

    # Run installation script
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
