#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ros.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:41:47 am
# @modified Sunday, 7th November 2021 5:12:45 pm
# @project  BashUtils
# @source   https://docs.ros.org/en/$ROS2_DISTRO/Installation/Ubuntu-Install-Binary.html
# @source   https://docs.ros.org/en/$ROS2_DISTRO/Installation/Ubuntu-Install-Debians.html
# @brief
#    
#    Installation/Uninstallation script for ROS2 
#
# @ntoe This script supports ROS2 Foxy and ROS2 Galactic    
# @note This script assumes that `source_me.bash` script from th project's root directory was previously sourced
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs/uninstalls ROS2 foxy edition using apt packages manager
    Usage: foxy_pkg.bash ACTION SRC

    Arguments:

        ACTION  action to be performed by the script (either 'install' or 'uninstall')
           SRC  installation source (either 'bin' for binary-package based installation
                or 'pkg' for apt-based installation)

    Options:
      
        --help  displays this usage message

    Environment:

        ROS2_INSTALLATION_PATH  installation path of the ROS when 'bin' installation/uninstallation
                                is performed (default: /opt/ros/foxy)
                   ROS2_DISTRO  distribution to be installed. Currently supported are:
                                    - foxy
                                    - galactic
END

# ============================================================ Constants =========================================================== #

# List of supported distributions
declare -a ROS2_SUPPORTED_DISTROS=(
    foxy
    galactic
)

# Script's log context
LOG_CONTEXT="ros2"

# ========================================================== Configruation ========================================================= #

# Default destination of the ROS2
ROS2_DEFAULT_INSTALLATION_PATH='/opt/ros/foxy'
# Destination of the ROS2
var_set_default ROS2_INSTALLATION_PATH "$ROS2_DEFAULT_INSTALLATION_PATH"
# Distributon to be installed
var_set_default ROS2_DISTRO ''

# ============================================================ Functions =========================================================== #

add_ros_repo() {

    # URL of the ROS2 GPG key
    local ROS2_GPG_URL="https://raw.githubusercontent.com/ros/rosdistro/master/ros.key"
    # Destination of the PGP key
    local ROS2_GPG_PATH="/usr/share/keyrings/ros-archive-keyring.gpg"
    # URL of the ROS2 Ubuntu repository
    local ROS2_REPO_URL="http://packages.ros.org/ros2/ubuntu"
    # Path to the source file of the ROS2 Ubuntu repository
    local ROS2_APT_SOURCE_PATH="/etc/apt/sources.list.d/ros2.list"

    # Authorise ROS2 GPG key
    if [[ ! -f "$ROS2_GPG_PATH" ]]; then
        sudo curl -sSL "$ROS2_GPG_URL" -o "$ROS2_GPG_PATH"
    fi

    # Create apt source file pointing to the ROS2 Ubuntu repository
    if [[ ! -f "$ROS2_APT_SOURCE_PATH" ]]; then

        # Prepare source file's content
        local APT_SOURCE_CMD="deb [arch=$(dpkg --print-architecture) signed-by=$ROS2_GPG_PATH] $ROS2_REPO_URL $(lsb_release -cs) main"
        # Write content to the file
        echo "$APT_SOURCE_CMD" | sudo tee "$ROS2_APT_SOURCE_PATH" > /dev/null

    fi
    
}


install_ros_pkg() {
    install_pkg ros-$ROS2_DISTRO-desktop
}


install_ros_bin() {
    
    # Download folder for binaries
    local ROS2_DOWNLOAD_DIR="/tmp"
    # Download folder for binaries
    local ROS2_BIN_DOWNLOAD_PATH="$ROS2_DOWNLOAD_DIR/ros2_$ROS2_DISTRO.tar.bz2"

    # --------------------------- Dependencies ---------------------------

    # List of dependencies packages
    local dependencies_=(
        libpython3-dev     # Developers tools for python3 
        python3-pip        # PIP packages manager
        python3-catkin-pkg # ROS2 requires v0.4.24 while Ubuntu Foxy provides v0.4.16 by default
    )

    # Python dependencies
    local ros_python_dependencies=(
        argcomplete # ROS autocompletion tool
    )

    # Install additional dependencies
    install_packages -yv --su -U dependencies_
    
    # Install python dependencies
    logc_info "Installing additional ROS2 python dependencies"
    echo "${ros_python_dependencies[@]}" | tr ' ' '\n' | map pip_install_upgrade_package

    # --------------------------- Installation ---------------------------

    # Get directory and basename of the destination folder
    local ROS2_INSTALLATION_PATH_DIR=$(dirname $ROS2_INSTALLATION_PATH)
    local ROS2_INSTALLATION_PATH_BASE=$(basename $ROS2_INSTALLATION_PATH)
    # Prepary output directory
    mkdir -p "$ROS2_INSTALLATION_PATH_DIR"

    # Download and extract ROS2-Foxy binaries
    LOG_CONTEXT=$LOG_CONTEXT LOG_TARGET="ROS2 binaries" download_and_extract -v \
        $(get_ros_bin_url) $(dirname $ROS2_BIN_DOWNLOAD_PATH) $ROS2_INSTALLATION_PATH_DIR || return 1

    # Rename destination directory
    mv $ROS2_INSTALLATION_PATH_DIR/ros2-linux $ROS2_INSTALLATION_PATH

    # Remove sources
    if [[ $BASH_UTILS_RM_DOWNLOADED -eq "1" ]]; then
        logc_info "Deleting downloaded sources..."
        rm -rf $ROS2_BIN_DOWNLOAD_PATH
        logc_info "Sources deleted"
    fi
    
}


install_ros() {

    # If 'pkg' installation, force default isntallation path
    [[ $src == "pkg" ]] && ROS2_INSTALLATION_PATH="$ROS2_DEFAULT_INSTALLATION_PATH"

    # -------------------------- Configuration ---------------------------

    # Path to the default configuration of the rosdep
    local ROS2_ROSDEP_DEFAULT_CONFIG_PATH=/etc/ros/rosdep/sources.list.d/20-default.list

    # --------------------------- Dependencies ---------------------------

    # List of dependencies packages
    local dependencies=(
        locales                          # Locales utilities
        curl                             # Utility to download files from online servers
        gnupg2                           # Implementation of the OpenPGP standard (encryption)
        lsb-release                      # Utilities related to distro-specific informations
        python3-rosdep2                  # ROS' dependencies utility
        python3-colcon-common-extensions # `colcon` build system
    )

    # Python dependencies
    local ros_python_dependencies=(
        argcomplete # ROS autocompletion tool
        vcstool     # Repository-management
    )

    # ROS dependencies to be skipped
    local rosdep_skip_dependencies=(
        cyclonedds 
        fastcdr 
        fastrtps 
        rti-connext-dds-5.3.1 
        urdfdom_headers 
    )
        
    # ---------------------------------- Pre-check ----------------------------------

    # Check if ROS is already installed
    [[ -f $ROS2_INSTALLATION_PATH/setup.bash ]] && return
    
    # Check whether current locale supports UTF-8
    locale |
    while read line; do 

        local valid_locale=1

        # Check if a locale configuration supports UTF-8
        if [[ ! "$line" =~ .*UTF-8|.*= ]]; then
            
            # If the dirst uncompatibile setting detected, print error
            if [[ valid_locale == "0" ]]; then
                logc_error "Locales does not fully support UTF-8 encodeing:"
                valid_locale=0
            fi
            # Print incompatibile line to the user
            echo $line

        fi

        # If locale invalid, return
        if [[ valid_locale == "0" ]]; then
            return 1
        fi

    done
    
    # ------------------------------ Preconfigruation -------------------------------

    # Source distros-specific routines
    source $(get_script_dir)/$ROS2_DISTRO.bash

    # Run distro-specific preparation routine
    is_function_defined prepare_ros_installation && 
        prepare_ros_installation
    
    # Add ROS repositories to apt
    add_ros_repo
    
    # Install dependencies
    sudo apt update && install_packages -yv --su dependencies

    # Install python dependencies
    logc_info "Installing ROS2 python dependencies"
    echo "${ros_python_dependencies[@]}" | tr ' ' '\n' | map pip_install_upgrade_package
    
    # -------------------------------- Installation ---------------------------------

    logc_info "Installing ROS2 to $ROS2_DEFAULT_INSTALLATION_PATH..."
    
    # Install ROS2 package (desktop-version)
    [[ $src == "pkg" ]] && install_ros_pkg ||
    [[ $src == "bin" ]] && install_ros_bin

    logc_info "ROS2 installed"

    # --------------------------- `rosdep` configuration ----------------------------

    # Set variables required by rosdep
    export ROS_PYTHON_VERSION=3
    
    # Initialize rosdep
    logc_info "Updating rosdep..."
    [[ -f $ROS2_ROSDEP_DEFAULT_CONFIG_PATH ]] || sudo rosdep init
    rosdep update
    # Install rosdep dependencies
    logc_info "Installing ROS2-rosdep dependencies."
    rosdep install                                   \
        --rosdistro=$ROS2_DISTRO                     \
        --from-paths $ROS2_INSTALLATION_PATH/share   \
        --ignore-src -y                              \
        --skip-keys="${rosdep_skip_dependencies[0]}"

}


uninstall_ros() {

    # For binary installation, remove ROS folder
    [[ $src == "bin" ]] && rm -rf $ROS2_INSTALLATION_PATH

    # Uninstall ROS-related apt packages
    sudo apt remove ~nros-$ROS2_DISTRO-* && sudo apt autoremove
}

# ============================================================== Main ============================================================== #

main() {

    # Arguments
    local action
    local src

    # Options
    local defs=(
        '--help',help,f
    )

    # Parsed options
    parse_arguments

    # Parse arguments
    action=${1:-}
    src=${2:-}

    # Verify arguments
    [[ $#      == "2"                                 ]] &&
    [[ $action == "install" || $action == "uninstall" ]] &&
    [[ $src    == "bin"     || $src    == "pkg"       ]] || { 
        logc_error "Usage error"
        echo $usage
        return 1
    }

    # Verify distro
    is_one_of "$ROS2_DISTRO" ROS2_SUPPORTED_DISTROS || {
        logc_error "Unsupported distro given ($(print_var ROS2_DISTRO))"
        return 1
    }

    # Change lgo context
    LOG_CONTEXT="$LOG_CONTEXT-$ROS2_DISTRO"

    # Check usage
    if [[ $action == 'install' ]]; then
        install_ros
    elif [[ $action == 'uninstall' ]]; then
        uninstall_ros
    fi
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
