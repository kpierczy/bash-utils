#!/usr/bin/env bash
# ====================================================================================================================================
# @file     zlib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Friday, 25th February 2022 4:51:36 am
# @project  bash-utils
# @brief
#    
#    Installation routines for zlib library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source common function
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/common.bash

# ============================================================ Functions =========================================================== #

function build_zlib() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a BUILD_FLAGS=()

    # Prepare config flags (place in .../zlib foler to to prevent GCC linking this version of Zlib)
    CONFIG_FLAGS+=( "--prefix=${dirs[install_host]}/zlib" )

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'zlib'

}
