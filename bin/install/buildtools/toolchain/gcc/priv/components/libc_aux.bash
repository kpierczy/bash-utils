#!/usr/bin/env bash
# ====================================================================================================================================
# @file     libc_aux.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Saturday, 26th February 2022 7:08:38 pm
# @project  bash-utils
# @brief
#    
#    Installation routines for libc library (auxiliary build)
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source components-builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/libc/glibc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/libc/newlib.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/libc/ulibc.bash

# =========================================================== Dispatcher =========================================================== #

function build_libc() {

    # Dispatch build depending on the library version
    case ${opts[with_libc]} in
        'glibc'       ) build_glibc  'aux' ;;
        'newlib'      ) build_newlib 'aux' ;;
        'ulibc'       ) build_ulibc  'aux' ;;
    esac

}
