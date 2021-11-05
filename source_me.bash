#!/usr/bin/env bash
# ====================================================================================================================================
# @file     source_me.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:18:45 pm
# @modified Friday, 5th November 2021 2:07:43 pm
# @project  BashUtils
# @brief
#    
#    Main source script of the BashUtils project. Sourcing it will provide a shell with all functions and aliases defined in the
#    project's library as well ass will exted PATH with directories holding helper scripts and programms.
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Check bash version
if (( BASH_VERSINFO[0] < 4 )); then
    echo "Bash Lib requires bash v4 or greater"
    echo "Current Bash Version: ${BASH_VERSION}"
    exit 1
fi

# Set library home path
BASH_UTILS_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# ============================================================= Sources ============================================================ #

# Source library
source $BASH_UTILS_HOME/lib/lib.bash

# Source bin config
source $BASH_UTILS_HOME/bin/config.bash

# Enable aliases' expansion
set_aliases_expansion on

# ====================================================== Install dependencies ====================================================== #

# List of dependencies
declare dependencies=(
    pv # Progress-monitor
)

# Install dependencies
install_packages -yv --su dependencies || return 1

# ========================================================= Set environment ======================================================== #

# Export lib's root  dircetory
export BASH_UTILS_HOME

# Add `shpec` library to the PATH
PATH+=:"$BASH_UTILS_HOME/dep/shpec/bin"

# Add ./bin directory PATH
PATH+=:"$BASH_UTILS_HOME/dep/shpec/bin"

# ============================================================= Cleanup ============================================================ #

unset deps
