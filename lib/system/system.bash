#!/usr/bin/env bash
# ====================================================================================================================================
# @file     system.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 2:15:51 pm
# @modified Sunday, 21st November 2021 2:19:35 pm
# @project  BashUtils
# @brief
#    
#    Set of system related to the general inspection of the host system
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Write's syetm architecture to the stdout
# @note This function returns architecture string reported by the 'uname' utility
# ---------------------------------------------------------------------------------------
get_system_arch() {
    echo $(uname -m)
}
