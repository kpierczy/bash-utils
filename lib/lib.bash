#!/usr/bin/env bash
# ====================================================================================================================================
# @file     lib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:45:51 am
# @modified Monday, 21st February 2022 10:17:57 pm
# @project  bash-utils
# @brief
#    
#    File consolidating `source` calls to all scripts defined in the library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Constants =========================================================== #

# Enable default word-splitting to properly parse arrays
declare OLD_IFS="$IFS"
unset IFS

# Find all sources of the library (relies on a default word-splitting)
declare -a BASH_UTILS_LIB_SOURCES=( $(
    find $BASH_UTILS_HOME/lib -name "*.bash" \
        ! -name "lib.bash"                   \
        ! -path "*templates*"                \
        ! -path "*examples*"
))

# Find all script templates implemented by the library (relies on a default word-splitting)
declare -a BASH_UTILS_TEMPLATE_SOURCES=( $(find $BASH_UTILS_HOME/lib -path "*/templates/*.bash") )

# Restore initial word-splitting
IFS="$OLD_IFS"
unset OLD_IFS

# ========================================================= Source sources ========================================================= #

# Source all library sources
for src in "${BASH_UTILS_LIB_SOURCES[@]}"; do
    source "$src"
done
