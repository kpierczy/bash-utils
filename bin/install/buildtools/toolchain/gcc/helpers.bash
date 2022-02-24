#!/usr/bin/env bash
# ====================================================================================================================================
# @file     helpers.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 7th November 2021 3:08:11 pm
# @modified Thursday, 24th February 2022 12:22:01 am
# @project  bash-utils
# @brief
#    
#    Implementation of helper functions
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ---------------------------------------------------------------------------------------
# @brief Returns identifier of the current machine
# @outputs
#     identifier of the current machine 
# ---------------------------------------------------------------------------------------
function get_host() {

    # Get system name
    local uname_string=`uname | sed 'y/LINUXDARWIN/linuxdarwin/'`
    # Get machine
    local host_arch=`uname -m | sed 'y/XI/xi/'`

    # For Linux-based machines
    if [ "x$uname_string" == "xlinux" ] ; then
        echo "${host_arch}-linux-gnu"
    # For others
    else
        echo "<non-supported-host>"
    fi
}
