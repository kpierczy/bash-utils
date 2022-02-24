#!/usr/bin/env bash
# ====================================================================================================================================
# @file     newlib-nano.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 3:12:39 am
# @project  bash-utils
# @brief
#    
#    Installation routines for newlib-nano tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function build_newlib_nano() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"                         )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                           )
    CONFIG_FLAGS+=( "--target=${opts[target]}"                       )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}"                       )

    # ------------------------------- Prepare environment -------------------------------

    # Clear helper stack to put envs on
    clear_env_stack
    # Add compiled GCC's binaries to path
    prepend_path_env_stack ${dirs[prefix]}/bin

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'libc'
    
}
