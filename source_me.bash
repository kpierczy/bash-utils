#!/usr/bin/env bash
# ====================================================================================================================================
# @file       source_me.bash
# @author     Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @maintainer Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date       Tuesday, 2nd November 2021 10:18:45 pm
# @modified   Wednesday, 25th May 2022 1:37:42 pm
# @project    bash-utils
# @brief      Script that should be source before starting using the project
# @details    
#
#    Main source script of the `bash-utils`` project. Sourcing it will provide a shell with all functions and aliases defined in the
#    project's library as well as will exted PATH with directories holding helper scripts and programms.
#    
#    One may source this script with the 'setup' keyword which will make the script to verify project's system dependencies and
#    install lacking ones. It is required to run update command at least once after cloning the repository. This is provided
#    to ommit repeating dependencies' check at each sheell using `bash-utils`
#
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ========================================================== Requirements ========================================================== #

# Check bash version (required >= 4.2)
if (( BASH_VERSINFO[1] < 3 )) && (( BASH_VERSINFO[0] <= 4 )); then
    echo "bash-utils lib requires bash v4 or greater"
    echo "Current Bash Version: ${BASH_VERSION}"
    return 1
fi

# ============================================================== Setup ============================================================= #

# Set library home path
export BASH_UTILS_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# ============================================================= Sources ============================================================ #

# Enable globbing' expansion
shopt -s extglob
# Enable aliases' expansion
shopt -s expand_aliases

# Source library
source $BASH_UTILS_HOME/lib/lib.bash

# ===================================================== Additional requirements ==================================================== #

# Check `getopt` version
getopt -T &>/dev/null
if (( $? != 4 )); then
    echo "bash-utils lib requires so called 'enhanced' (or GNU) getop version to work"
    return 1
fi

# ====================================================== Install dependencies ====================================================== #

# Setup project
if [[ "$1" == 'setup' ]]; then

    # List of dependencies
    declare dependencies=(
        
        # Python
        python3
        python3-pip
        
        # Web utilities
        curl

        # Archieves utilities
        tar      
        zip      
        unzip    
        fuse-zip 

        # General utilities
        pv       

    )

    # List of Python dependencies
    declare pip_dependencies=(
        
        # Archieves utilities
        tqdm

    )

    # Install dependencies
    install_pkg_list -yv --su dependencies || return 1
    # Install Python dependencies
    pip_install_list -v pip_dependencies || return 1

fi

# ========================================================= Set environment ======================================================== #

# Export lib's root  dircetory
export BASH_UTILS_HOME

# Add `shpec` library to the PATH
append_path "$BASH_UTILS_HOME/dep/shpec/bin"

# Add ./bin directory PATH
append_path "$BASH_UTILS_HOME/bin"
# Add variable pointing to the ./bin directory
declare BASH_UTILS_BIN_HOME="$BASH_UTILS_HOME/bin"

# Add ./scripts directory PATH
append_path "$BASH_UTILS_HOME/scripts"

# ============================================================= Cleanup ============================================================ #

unset dependencies
unset pip_dependencies
