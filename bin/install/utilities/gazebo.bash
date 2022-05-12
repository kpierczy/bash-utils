# ====================================================================================================================================
# @file     gazebo.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 6th March 2022 7:30:26 pm
# @modified   Thursday, 12th May 2022 9:47:33 pm
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
declare LOG_CONTEXT="gazebo"

# Default apt key URL
declare APT_KEY_URL='https://packages.osrfoundation.org/gazebo.gpg'

# ============================================================== Main ============================================================== #

function install() {
        
    local package

    # Select target package depending on the Ubuntu version
    case $(lsb_release -sd) in
    
        # OS supported by the script
        "Ubuntu 20.04 LTS" ) package="gazebo11" ;;
        "Ubuntu 22.04 LTS" ) package="gazebo"   ;;
        # OS NOT supported by the script
        * )
            log_error "OS version not supported ($(lsb_release -sd))"
            return 1 ;;
    esac

    # Check if Webots is installed already
    is_pkg_installed "$package" && return 0

    log_info "Adding Gazebo repository to apt..."

    # Repo string to be palced in apt sources
    local APT_REPO_STRING="deb [arch=amd64,arm64] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main"
    # Repo file for APT
    local APT_REPO_FILE="/etc/apt/sources.list.d/gazebo-stable.list"

    # Add apt key
    curl -s "$APT_KEY_URL" | sudo tee "/etc/apt/trusted.gpg.d/gazebo.gpg" > /dev/null
    # Setup package server
    echo "$APT_REPO_STRING" | sudo tee "$APT_REPO_FILE" > /dev/null
    
    log_info "Updating apt..."

    # Update apt
    sudo apt-get update
    
    log_info "Instsalling..."
    
    # Install the simulator
    install_pkg --su -y -v "$package" || {
        log_error "Failed to install $package package"
        return 1
    }
    
    log_info "Sucesfully installed"
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/simple_install.bash
