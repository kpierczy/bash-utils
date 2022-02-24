#!/usr/bin/env bash
# ====================================================================================================================================
# @file     common.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 6:31:08 am
# @project  bash-utils
# @brief
#    
#    Set of common installation routines for libraries and components
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ---------------------------------------------------------------------------------------
# @brief Builds a library
# 
# @param name
#    name of the library (lower case)
# @environment
#
#   CONFIG_FLAGS  array containing configuration options for the build
#   COMPILE_FLAGS array containing compilation options for the build
# ---------------------------------------------------------------------------------------
function build_component() {
    
    local name="$1"

    # ---------------------------- Prepare building options -----------------------------

    # Parse --force flag
    local force_flag=""
    is_var_set opts[force] && force_flag="--force"

    # ------------------------------ Prepare custom flags -------------------------------

    # Enable word splitting to parse flags in an apprpriate way
    localize_word_splitting
    push_stack "$IFS"
    enable_word_splitting

    # Add custom config flags
    CONFIG_FLAGS+=( ${config_flags[common]} )
    CONFIG_FLAGS+=( ${config_flags[$name]}  )
    # Add custom compile flags
    COMPILE_FLAGS+=( ${compile_flags[common]} )
    COMPILE_FLAGS+=( ${compile_flags[$name]}  )

    # Restor the prevous word-splitting separator
    pop_stack IFS

    # ------------------------------- Prepare build flags -------------------------------

    local env_name

    # Initialize new envs stack
    clear_env_stack

    # Get reference to the common env array
    local -n common_build_env_ref=${build_env[common]}
    # Get reference to the spcific env array
    local -n specific_build_env_ref=${build_env[$name]}

    # Iterate over common build environment variables and set it
    if [[ ${#common_build_env_ref[@]} != "0" ]]; then
        for env_name in ${!common_build_env_ref[@]}; do
            push_env_stack $env_name ${common_build_env_ref[$env_name]}
        done
    fi
    # Iterate over specific build environment variables and set it
    if [[ ${#specific_build_env_ref[@]} != "0" ]]; then
        for env_name in ${!specific_build_env_ref[@]}; do
            push_env_stack $env_name ${specific_build_env_ref[$env_name]}
        done
    fi

    # -------------------------------------- Build --------------------------------------

    # Download, build and install library
    download_build_and_install ${urls[$name]}         \
        --verbose                                     \
        --arch-path=${dirs[download]}/${names[$name]} \
        --extract-dir=${dirs[src]}                    \
        --show-progress                               \
        --src-dir=${names[$name]}                     \
        --build-dir=${dirs[build]}/${names[$name]}    \
        --mark                                        \
        --log-target=${names[$name]}                  \
        $force_flag

    # ------------------------------------- Cleanup -------------------------------------

    # Restore environment
    restore_env_stack

}
