#!/usr/bin/env bash
# ====================================================================================================================================
# @file     helpers.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 7th November 2021 3:08:11 pm
# @modified Wednesday, 23rd February 2022 1:50:52 am
# @project  bash-utils
# @brief
#    
#    Implementation of helper functions
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ---------------------------------------------------------------------------------------
# @brief Returns identifier of the current machine
# @outputs
#     identifier of the current machine 
# ---------------------------------------------------------------------------------------
function get_machine() {
    echo "x86_64-pc-linux-gnu"
}

# ---------------------------------------------------------------------------------------
# @brief Returns default version of the given @p implementation of the libc
#
# @param implementation
#     implementation to be processed (one of: {glibc, newlib, ulibc})
# @outputs
#     default version of the given @p implementation
# ---------------------------------------------------------------------------------------
function get_default_libc_version() {

    # Arguments
    local implementation="$1"

    # Return default version
    case ${implementation} in
        'glibc'  ) echo "$TOOLCHAIN_GLIBC_VERSION"  ;;
        'newlib' ) echo "$TOOLCHAIN_NEWLIB_VERSION" ;;
        'ulibc'  ) echo "$TOOLCHAIN_ULIBC_VERSION"  ;;
    esac

}

# ---------------------------------------------------------------------------------------
# @brief Returns default download URL scheme of the given @p implementation of the libc
#
# @param implementation
#     implementation to be processed (one of: {glibc, newlib, ulibc})
# @outputs
#     default download URL scheme of the given @p implementation
# ---------------------------------------------------------------------------------------
function get_default_libc_url() {

    # Arguments
    local libc_implementation="$1"

    # Return default version
    case ${libc_implementation} in
        'glibc'  ) echo "$TOOLCHAIN_GLIBC_URL_SCHEME"  ;;
        'newlib' ) echo "$TOOLCHAIN_NEWLIB_URL_SCHEME" ;;
        'ulibc'  ) echo "$TOOLCHAIN_ULIBC_URL_SCHEME"  ;;
    esac

}
