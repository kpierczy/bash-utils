#!/usr/bin/env bash
# ====================================================================================================================================
# @file     common.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Saturday, 26th February 2022 6:59:58 pm
# @project  bash-utils
# @brief
#    
#    Set of common installation routines for libraries and components
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ---------------------------------------------------------------------------------------
# @brief Builds a target
# 
# @param target
#    name of the target
# @environment
#
#   CONFIG_FLAGS  array containing configuration options for the build
#   BUILD_FLAGS array containing compilation options for the build
# ---------------------------------------------------------------------------------------
function build_component() {
    
    local target="$1"

    # ---------------------------- Prepare building options -----------------------------

    local -a build_script_flags=()

    # Parse --force flag
    is_var_set opts[force] && build_script_flags+=( "--force" )
    # Parse --verbose-tools flag
    is_var_set opts[verbose_tools] && build_script_flags+=( "--verbose-tools" )

    # ------------------------------ Prepare custom flags -------------------------------

    local -n common_config_flags_ref=${config_flags[common]}
    local -n specific_config_flags_ref=${config_flags[$target]}

    # Add custom config flags
    CONFIG_FLAGS+=( ${common_config_flags_ref[@]}   )
    CONFIG_FLAGS+=( ${specific_config_flags_ref[@]} )

    local -n common_compile_flags_ref=${compile_flags[common]}
    local -n specific_compile_flags_ref=${compile_flags[$target]}

    # Add custom compile flags
    BUILD_FLAGS+=( ${common_compile_flags_ref[@]}   )
    BUILD_FLAGS+=( ${specific_compile_flags_ref[@]} )

    # ------------------------------- Prepare build flags -------------------------------

    local env_name

    # Initialize new envs stack
    clear_env_stack

    # Get reference to the common env array
    local -n common_build_env_ref=${build_env[common]}
    # Get reference to the spcific env array
    local -n specific_build_env_ref=${build_env[$target]}

    # Write down a common log when custom building environment is set
    if ! is_array_empty 'common_build_env_ref' || ! is_array_empty 'specific_build_env_ref'; then
        log_info "$(set_bold)Setting build environment...$(reset_colors)"
    fi
    
    # Iterate over common build environment variables and set it
    if ! is_array_empty 'common_build_env_ref'; then
        for env_name in ${!common_build_env_ref[@]}; do
            log_info "  $(set_bold)[$(set_fcolor 208)$env_name$(reset_colors)]$(set_bold)='${common_build_env_ref[$env_name]}'$(reset_colors)"
            push_env_stack $env_name ${common_build_env_ref[$env_name]}
        done
    fi
    # Iterate over specific build environment variables and set it
    if ! is_array_empty 'specific_build_env_ref'; then
        for env_name in ${!specific_build_env_ref[@]}; do
            log_info "  $(set_bold)[$(set_fcolor 208)$env_name$(reset_colors)]$(set_bold)='${specific_build_env_ref[$env_name]}'$(reset_colors)"
            push_env_stack $env_name ${specific_build_env_ref[$env_name]}
        done
    fi

    # -------------------------------------- Build --------------------------------------
    
    local ret
    
    # Download, build and install library
    download_build_and_install ${urls[$target]} \
        --verbose                               \
        --arch-path=${archieves[$target]}       \
        --extract-dir=${dirs[src]}              \
        --show-progress                         \
        --src-dir=${dirs[${target}_src]}        \
        --build-dir=${dirs[${target}_build]}    \
        --mark                                  \
        --log-target=${target//_/-}             \
        ${build_script_flags[@]}                \
    && ret=$? || ret=$?

    # ------------------------------------- Cleanup -------------------------------------

    # Restore environment
    restore_env_stack
        
    # If error occurred, return error
    if [[ $ret == "1" ]]; then
        return 1
    fi

    return 0
}
