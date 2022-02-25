#!/usr/bin/env bash
# ====================================================================================================================================
# @file     common.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Friday, 25th February 2022 5:07:44 pm
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
# @param build_dir_base (optional, default: $name)
#    name of the folder in the <build> directory that the component has to be built
#    into; this parameters is provided to enable building some components in stages
#    (e.g. GCC source is build a few times in a single toolchain's build: for compiler,
#    libgcc and libc++)
# @param src_dir_base (optional, default: $name)
#    basename of the folder in the <src> directory that the component's source will be
#    stored int; also basename for the soruce archieve; this parameters is provided to
#    enable building various components from the same source (e.g. newlib-nano is
#    trated as a different component but is built from the same package)
# @environment
#
#   CONFIG_FLAGS  array containing configuration options for the build
#   BUILD_FLAGS array containing compilation options for the build
# ---------------------------------------------------------------------------------------
function build_component() {
    
    local name="$1"
    local build_dir_base="${2:-$name}"
    local src_dir_base="${3:-$name}"

    # ---------------------------- Prepare building options -----------------------------

    local -a build_script_flags=()

    # Parse --force flag
    is_var_set opts[force] && build_script_flags+=( "--force" )
    # Parse --verbose-tools flag
    is_var_set opts[verbose_tools] && build_script_flags+=( "--verbose-tools" )

    # ------------------------------ Prepare custom flags -------------------------------

    local -n common_config_flags_ref=${config_flags[common]}
    local -n specific_config_flags_ref=${config_flags[$name]}

    # Add custom config flags
    CONFIG_FLAGS+=( ${common_config_flags_ref[@]}   )
    CONFIG_FLAGS+=( ${specific_config_flags_ref[@]} )

    local -n common_compile_flags_ref=${compile_flags[common]}
    local -n specific_compile_flags_ref=${compile_flags[$name]}

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
    local -n specific_build_env_ref=${build_env[$name]}

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

    # ------------------- Prepare build names (dispatch for libc case) ------------------

    # ----------------------------------------------------
    # @note Awful code... Change API to smething more 
    #    flexible to enable uniform treatment of libc
    # @fixme
    # ----------------------------------------------------

    # Prepare archive's path
    local archieve_path=${dirs[download]}/
    if [[ $name == 'libc' && $src_dir_base == $name ]]; then
        archieve_path+=${opts[with_libc]}-${versions[$name]}
    else
        archieve_path+=$src_dir_base-${versions[$name]}
    fi
    # Prepare relaitve soruce dir
    local src_dir=
    if [[ $name == 'libc' && $src_dir_base == $name ]]; then
        src_dir=${opts[with_libc]}-${versions[$name]}
    else
        src_dir=$src_dir_base-${versions[$name]}
    fi
    # Prepare build dir
    local build_dir=${dirs[build]}/
    if [[ $name == 'libc' && $build_dir_base == $name ]]; then
        build_dir+=${opts[with_libc]}-${versions[$name]}
    else
        build_dir+=$build_dir_base-${versions[$name]}
    fi
    # Prepare log name
    local log_name=""
    if [[ $name == 'libc' && $build_dir_base == $name ]]; then
        log_name=${opts[with_libc]}-${versions[$name]}
    else
        log_name=$build_dir_base-${versions[$name]}
    fi

    # -------------------------------------- Build --------------------------------------
    
    local ret
    
    # Download, build and install library
    download_build_and_install ${urls[$name]}                           \
        --verbose                                                       \
        --arch-path=$archieve_path                                      \
        --extract-dir=${dirs[src]}                                      \
        --show-progress                                                 \
        --src-dir=$src_dir                                              \
        --build-dir=$build_dir                                          \
        --mark                                                          \
        --log-target=$log_name                                          \
        ${build_script_flags[@]}                                        \
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
