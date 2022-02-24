#!/usr/bin/env bash
# ====================================================================================================================================
# @file     libc.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 1:04:47 am
# @project  bash-utils
# @brief
#    
#    Installation routines for libc tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source components-builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libc/glibc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libc/newlib.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libc/newlib-nano.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libc/ulibc.bash

# =========================================================== Dispatcher =========================================================== #

function build_libc() {

    # Dispatch build depending on the library version
    case ${opts[with_libc]} in
        'glibc'       ) build_glibc                     ;;
        'newlib'      ) build_newlib                    ;;
        'newlib-nano' ) build_newlib; build_newlib_nano ;;
        'ulibc'       ) build_ulibc                     ;;
    esac

}
