# ====================================================================================================================================
# @file     gazebo.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 6th March 2022 7:30:26 pm
# @modified Sunday, 6th March 2022 9:00:38 pm
# @project  engineering-thesis
# @brief
#    
#    Installation script for Gazebo simulator
#    
# @copyright Krzysztof Pierczyk © 2022
# @source http://gazebosim.org/tutorials?tut=install_ubuntu
# ====================================================================================================================================


# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs Gazebo simulator via apt package"

# ========================================================== Configruation ========================================================= #

# Logging context of the script
declare LOG_CONTEXT="webots"

# Default apt key URL
declare APT_KEY='https://packages.osrfoundation.org/gazebo.key'
# Default apt respository URL
declare APT_REPO='http://packages.osrfoundation.org/gazebo/ubuntu-stable'
# Default apt .list file
declare APT_LIST='/etc/apt/sources.list.d/gazebo-stable.list'

# ============================================================== Main ============================================================== #

function install() {

    # Check if Webots is installed already
    is_pkg_installed gazebo11 && return 0

    log_info "Adding Gazebo repository to apt..."

    # Setup package server
    sudo sh -c "echo \"deb $APT_REPO `lsb_release -cs` main\" > $APT_LIST"
    # Add apt key
    wget $APT_KEY -O - | sudo apt-key add -
    
    log_info "Updating apt..."

    # Update apt
    sudo apt-get update
        
    # Install the simulator
    install_pkg --su -y -v gazebo11
    
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

    # Run installation routine
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
