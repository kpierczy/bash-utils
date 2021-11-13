#!/usr/bin/env bash
# ====================================================================================================================================
# @file     source_me.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:18:45 pm
# @modified Saturday, 13th November 2021 5:20:50 am
# @project  BashUtils
# @brief
#    
#    Main source script of the BashUtils project. Sourcing it will provide a shell with all functions and aliases defined in the
#    project's library as well ass will exted PATH with directories holding helper scripts and programms.
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Check bash version (required >= 4.2)
if (( BASH_VERSINFO[1] < 3 )) && (( BASH_VERSINFO[0] <= 4 )); then
    echo "Bash Lib requires bash v4 or greater"
    echo "Current Bash Version: ${BASH_VERSION}"
    exit 1
fi

# Set library home path
BASH_UTILS_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# ============================================================= Sources ============================================================ #

# Source library
source $BASH_UTILS_HOME/lib/lib.bash

# Enable aliases' expansion
set_aliases_expansion on

# Resource library with enabled aliases' expansion
source $BASH_UTILS_HOME/lib/lib.bash

# ====================================================== Install dependencies ====================================================== #

# List of dependencies
declare dependencies=(
    pv       # Progress-monitor
    tar      # Tarball archieves tool
    zip      # ZIP archieves tool
    unzip    # ZIP archieves tool (extraction)
    fuse-zip # Mounting ZIP as filesystem
)

# List of Python dependencies
declare pip_dependencies=(
    tqdm     # Extracting ZIP files
)
# Install dependencies
install_pkg_list -yv --su dependencies || return 1
# Install Python dependencies
pip_install_list -v pip_dependencies || return 1

# ========================================================= Set environment ======================================================== #

# Export lib's root  dircetory
export BASH_UTILS_HOME

# Add `shpec` library to the PATH
append_path "$BASH_UTILS_HOME/dep/shpec/bin"

# Add ./bin directory PATH
append_path "$BASH_UTILS_HOME/bin"

# Add ./scripts directory PATH
append_path "$BASH_UTILS_HOME/scripts"

# ============================================================= Cleanup ============================================================ #

unset dependencies
unset pip_dependencies
