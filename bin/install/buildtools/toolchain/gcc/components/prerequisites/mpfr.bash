#!/usr/bin/env bash
# ====================================================================================================================================
# @file     mpfr.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Wednesday, 23rd February 2022 11:14:35 pm
# @project  bash-utils
# @brief
#    
#    Installation routines for mpfr library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source common function
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/common.bash

# ============================================================ Functions =========================================================== #

function build_mpfr() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"               )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                 )
    CONFIG_FLAGS+=( "--target=${opts[target]}"             )
    CONFIG_FLAGS+=( "--prefix=${dirs[install_host]}/usr"   )
    CONFIG_FLAGS+=( "--with-gmp=${dirs[install_host]}/usr" )

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'mpfr'

}
