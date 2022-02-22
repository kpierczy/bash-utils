#!/usr/bin/env bash
# ====================================================================================================================================
# @file     foxy.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 8:55:12 pm
# @modified Tuesday, 22nd February 2022 10:11:17 pm
# @project  bash-utils
# @brief
#    
#    ROS2-Foxy-specific installation routines
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function get_ros_bin_url() {

    # URL of the ROS2 Foxy binary package (amd64/Ubuntu-Focal, Patch Release 6.1)
    local ROS2_BIN_URL="https://github.com/ros2/ros2/releases/download/release-foxy-20211013/ros2-foxy-20211013-linux-focal-amd64.tar.bz2"

    # Print URL
    echo $ROS2_BIN_URL

}
