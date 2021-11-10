#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ros.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 11:27:25 pm
# @modified Wednesday, 10th November 2021 8:07:49 pm
# @project  Winder
# @brief
#    
#    Set of handy cmd-line-functions  related to the ROS (Robot Operating System)
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Builds colcon @p packages residing in @var COLCON_SOURCE_DIR
#
# @param packages...
#    list of packages to be built; if no @p packages are given, the 
#    whole @var COLCON_SOURCE_DIR dirctory is built
# 
# @options 
# 
#    --up-to  build packages with --packages-up-to flag (instead of 
#             --packages-select)
#         -v  verbose logs
#       --fv  full verbosity (logs + compiller commands)
#
# @environment
#
#    @var COLCON_SOURCE_DIR (path)
#       source directory of packages to be built (default: .)
#
# @todo test
# -------------------------------------------------------------------
function colbuild() {

    # Arguments
    # local packages_

    # ---------------- Parse arguments ----------------

    # Function's options
    declare -a defs=(
        '--up-to',up_to,f
        '-v',verbose,f
        '--fv',full_verbose,f
    )

    # Parse arguments to a named array
    parse_options

    # Set list of packages as positional arguments
    set -- "${posargs[@]}"

    # Get source directory
    local src_dir_="${COLCON_SOURCE_DIR:-.}"    

    # ----------------- Configure logs ----------------

    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    if is_var_set options[full_verbose] || is_var_set options[verbose]; then
        enable_stdout_logs
    else
        disable_stdout_logs
    fi

    # Set log context
    local LOG_CONTEXT="ros"

    # ----------- Prepare build environment -----------

    # Set verbose build flags
    local build_flags_=""
    is_var_set options[full_verbose] &&
        build_flags_+="--event-handlers console_direct+ "
     
    # Compile colcon build
    local build_type_
    is_var_set options[up_to] && 
        build_type_="--packages-up-to" ||
        build_type_="--packages-select"

    # If verbose build requested, export VERBOSE variable for CMake
    is_var_set options[full_verbose] &&
        export VERBOSE=1

    # ----------- Prepare build environment -----------

    # Check for dependencies
    log_info "Checking for dependencies"
    rosdep install -i --from-path src -y

    log_info "Building package(s) ..."

    # If no packages' names given, build the whole directory
    if [[ $# -eq 0 ]]; then

        colcon build --base-paths "$src_dir_" $build_flags_
        
    # Else, build listed packages
    else 

        local package_

        # Iterate over packages
        for package_ in "$@"; do
            
            # Build package
            if colcon build --base-paths "$src_dir_" $build_type_ $package_ $build_flags_; then
                log_error "Failed to build \'$package_\' package"
                restore_log_config_from_default_stack
                return 1
            else
                log_info "ros" "\'$package\' package built"
            fi
            
        done
    fi

    # Restore logs state
    restore_log_config_from_default_stack
    
}

# -------------------------------------------------------------------
# @brief Reinitializes rosdep
# -------------------------------------------------------------------
function reset_rosdep() {

    # Remove default configuration
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list

    # Initialize & update rosdep
    rosdep init && rosdep update

}
