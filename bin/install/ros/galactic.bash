#!/usr/bin/env bash
# ====================================================================================================================================
# @file     galactic.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 8:55:12 pm
# @modified Tuesday, 22nd February 2022 9:43:59 pm
# @project  bash-utils
# @brief
#    
#    ROS2-Galactic-specific installation routines
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function prepare_ros_installation() {

    # List of dependencies packages
    local dependencies_=(
        software-properties-common
    )

    # Install additional dependencies
    install_pkg_list -yv --su dependencies_

    # Read apt cache policy
    policy=$(apt-cache policy)

    # @note 'http://us.' -> 'http://pl.' (according to installation tutorial)
    local verification_string="500 http://pl.archive.ubuntu.com/ubuntu focal/universe amd64 Packages release v=20.04,o=Ubuntu,a=focal,n=focal,l=Ubuntu,c=universe,b=amd64"

    # Enable words-splitting for the function (enables printing $policy replacing \n with ' ')
    local IFS;
    enable_word_splitting

    # Check whether Ubuntu Universe repository is enabled
    if ! echo $policy | grep "$verification_string" > /dev/null; then
        sudo add-apt-repository universe
    fi

}


function get_ros_bin_url() {

    # URL of the ROS2 Foxy binary package (amd64/Ubuntu-Focal, Patch Release 6.1)
    local ROS2_BIN_URL="https://github.com/ros2/ros2/releases/download/release-galactic-20210716/ros2-galactic-20210616-linux-focal-amd64.tar.bz2"

    # Print URL
    echo $ROS2_BIN_URL

}
