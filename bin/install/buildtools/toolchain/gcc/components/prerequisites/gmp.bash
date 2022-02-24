#!/usr/bin/env bash
# ====================================================================================================================================
# @file     gmp.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 12:37:07 am
# @project  bash-utils
# @brief
#    
#    Installation routines for gmp library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source common function
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/common.bash

# ============================================================ Functions =========================================================== #

function build_gmp() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"               )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                 )
    CONFIG_FLAGS+=( "--prefix=${dirs[install_host]}/usr"   )

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'gmp'

}
