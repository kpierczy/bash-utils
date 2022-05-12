#!/usr/bin/env bash
# ====================================================================================================================================
# @file     humble.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 8:55:12 pm
# @modified   Thursday, 12th May 2022 8:52:24 pm
# @project  bash-utils
# @brief
#    
#    ROS2-Humble-specific installation routines
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Constants =========================================================== #

# URL of the ROS2 Ubuntu repository
declare ROS2_REPO_URL="http://packages.ros.org/ros2-testing/ubuntu"
# Log info about usage of test-release repository
log_warn                                                                                                   \
    "ROS2 humble is currently configured to be sourced from the 'ros2-testing/ubuntu' repository. This is" \
    "temporary source which will switch to standard 'ros2/ubuntu' after official release of ROS2"          \
    "Humble Hawksbill on May 23rd, 2022. If the distribution has been already released, please update"     \
    "'bash-utils/bin/install/ros/humble.bash' to point to the standard repository"

# ============================================================ Functions =========================================================== #

function prepare_ros_installation() {

    # List of dependencies packages
    local dependencies_=(
        software-properties-common
    )

    # Install additional dependencies
    install_pkg_list -yv --su dependencies_

    # @note 'http://us.' -> 'http://pl.' (according to installation tutorial)
    local verification_string=$(echo                                                         \
        "500 http://pl.archive.ubuntu.com/ubuntu $(lsb_release -sc)/universe amd64 Packages" \
        "release v=$(lsb_release -rs),o=Ubuntu,a=$(lsb_release -sc),n=$(lsb_release -sc),l=Ubuntu,c=universe,b=amd64"
    )

    # Read apt cache policy
    policy=$(apt-cache policy)
    
    # Enable words-splitting for the function (enables printing $policy replacing \n with ' ')
    local IFS;
    enable_word_splitting

    # Check whether Ubuntu Universe repository is enabled
    if ! echo $policy | grep "$verification_string" > /dev/null; then
        log_info "Adding 'universe' repository to APT..."
        sudo add-apt-repository universe
    fi

}
