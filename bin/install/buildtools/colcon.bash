#!/usr/bin/env bash
# ====================================================================================================================================
# @file     colcon.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 14th February 2022 3:08:56 pm
# @modified Monday, 14th February 2022 4:00:35 pm
# @project  bash-utils
# @brief
#    
#    Installation script for the colcon
#    
# @source
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs colcon build system
    Usage: colcon.bash

    Options:

        --help     displays this usage message

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="colcon"

# ========================================================== Configruation ========================================================= #

# URL of the apt identification key
declare APT_KEY_URL='https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc'

# ============================================================== Main ============================================================== #

install() {

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

main() {

    local -n USAGE=usage

    # Options
    local opt_definitions=(
        '--help',help,f
    )

    # Parsed options
    parse_arguments

    # Run installation script
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
