#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ros.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:41:47 am
# @modified Thursday, 4th November 2021 1:42:14 am
# @project  BashUtils
# @brief
#    
#    Installation script for ROS2
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Get script's home
SCRIPT_HOME=$(dirname $(readlink -f $BASH_SOURCE))

# Source BashUtils library
source $SCRIPT_HOME/../lib/lib.bash

# Enable aliases' expansion
set_aliases_expansion on
# Disable default words' splittinf
disale_word_splitting

# ========================================================== Configruation ========================================================= #

# ============================================================== Main ============================================================== #

main() {

    # Make sure that the Ubuntu Universe repository is enabled
    apt-cache policy | grep universe
    # Set verification string
    ubuntu_universe_signature="500 http://us.archive.ubuntu.com/ubuntu focal/universe amd64 Packages release v=20.04,o=Ubuntu,a=focal,n=focal,l=Ubuntu,c=universe,b=amd64"
    # 

}

# ============================================================= Script ============================================================= #

# If script was sourced, exit
is_sourced && return
# Enable strict mode
strict_mode on

# Run script
main $@
