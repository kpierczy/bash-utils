#!/usr/bin/env bash
# ====================================================================================================================================
# @file     prerequisites.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 6:22:01 am
# @project  bash-utils
# @brief
#    
#    Installation routines for prerequisites tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source prerequisites builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/zlib.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/gmp.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/mpfr.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/mpc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/isl.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/libelf.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/expat.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites/cloog.bash

# =========================================================== Dispatcher =========================================================== #

function build_prerequisites() {
    
    # Prepare list of prerequisites to be built (in order)
    local -a prerequisites_list=(
        zlib
        gmp
        mpfr
        mpc
        isl
        libelf
        expat
        cloog
    )

    # Prepare array of prerequisites's names
    local -A prerequisites=(
        [zlib]="Zlib"
        [gmp]="GMP"
        [mpfr]="MPFR"
        [mpc]="MPC"
        [isl]="ISL"
        [libelf]="libelf"
        [expat]="Expat"
        [cloog]="Cloog"
    )

    local lib

    # Build subsequent libraries
    for lib in ${prerequisites_list[@]}; do

        local libname=${prerequisites[$lib]}

        # Wait for user's confirmation to build the next component
        is_var_set opts[autocontinue] || {
            log_info "Press a key to start building the $libname library"; read
        }

        log_info "Building $libname library..."

        # Get name of the corresponding function
        local build_cmd="build_$lib"
        # Build component
        $build_cmd && ret=$? || ret=$?
        
        # Verify result of building
        if [[ "$ret" != "0" ]]; then
            log_error "Failed to build $libname library"
            return 1
        else
            log_info "${libname^} library built"
        fi
        
    done


}
