#!/usr/bin/env bash
# ====================================================================================================================================
# @file     lib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:45:51 am
# @modified Tuesday, 9th November 2021 7:54:33 pm
# @project  BashUtils
# @brief
#    
#    File consolidating `source` calls to all scripts defined in the library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Constants =========================================================== #

# Find all sources of the library
declare -a BASH_UTILS_LIB_SOURCES=( $(find $BASH_UTILS_HOME/lib -name "*.bash" ! -name "lib.bash" ! -path "*templates*") )

# Find all script templates implemented by the library
declare -a BASH_UTILS_TEMPLATE_SOURCES=( $(find $BASH_UTILS_HOME/lib -path "*/templates/*.bash") )

# ========================================================= Source sources ========================================================= #

# Source all library sources
for src in "${BASH_UTILS_LIB_SOURCES[@]}"; do
    source "$src"
done
