# ====================================================================================================================================
# @file     cmake.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 29th November 2021 11:46:21 am
# @modified Monday, 29th November 2021 3:16:37 pm
# @project  Winder
# @brief
#    
#    Set of tools related to building software from source using CMake
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Builds and installs CMake project
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 on error
# @options
#
#     -s|--src-dir=DIR  source directory (default: .)
#   -b|--build-dir=DIR  directory where the build action should be performed. Directory
#                       will be created if not exists (default: --src-dir/build)
# -i|--install-dir=DIR  installation directory (default .)
#         -v|--verbose  if set, the building process will print verbose logs
#    --log-target=NAME  name of the target to be configured printed in the logs (if not
#                       given, the default logs will be printed based on the source and 
#                       build directories) (default: basename of the source directory)
#   -t|--target=TARGET  target to be built
#
# @environment
#
#    CMAKE_CONFIG_FLAGS  name of the array containing additional command line options 
#                        that will be passed to the CMake at configuation step
#     CMAKE_BUILD_FLAGS  name of the array containing additional command line options 
#                        that will be passed to the CMake at building step
#
# ---------------------------------------------------------------------------------------
function cmake_build_install() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--src-dir',src_dir
        '-b|--build-dir',build_dir
        '-i|--install-dir',install_dir
        '-v|--verbose',verbose,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # Get source directory
    local src_dir=$(realpath -m ${options[src_dir]:-.})
    # Get build directory
    local build_dir=$(realpath -m ${options[build_dir]:-${src_dir}/build})
    # Get installation directory
    local install_dir=$(realpath -m ${options[install_dir]:-.})

    # ----------------- Configure logs ----------------  

    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set options[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # Get log target
    local LOG_TARGET=${options[log_target]:-$(basename $(realpath ${src_dir}))}

    # ---------------- Build and install --------------  

    log_info "Installing $LOG_TARGET..."

    # Create build directory
    mkdir -p $build_dir || {
        log_error "Failed to create build directory to build $LOG_TARGET"
        restore_log_config_from_default_stack
        return 1
    }
    
    # Move to the build directory
    pushd $build_dir > /dev/null
    # Prepare custom flags if given
    local no_flags=()
    local -n config_flags=${CMAKE_CONFIG_FLAGS:-no_flags}
    local -n build_flags=${CMAKE_BUILD_FLAGS:-no_flags}
    # Configure build system and buld
    cmake $src_dir                                  \
        "${config_flags[@]}"                        \
        -DCMAKE_INSTALL_PREFIX:PATH=$install_dir && \
    cmake --build . --target install                \
        "${build_flags[@]}"                      || \
    {
        log_error "Failed to install $LOG_TARGET"
        restore_log_config_from_default_stack
        popd > /dev/null
        return 1
    }

    # -------------------------------------------------  

    # Restore logs settings
    restore_log_config_from_default_stack
    # Return to the previous directory
    popd > /dev/null

    log_info "$LOG_TARGET library installed"
}
