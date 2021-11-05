#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ros.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 11:27:25 pm
# @modified Friday, 5th November 2021 7:29:01 pm
# @project  Winder
# @brief
#    
#    Set of handy cmd-line-functions  related to the ROS (Robot Operating System)
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source logging helper
source $BASH_UTILS_HOME/lib/logging/logging.bash
# Source general scripting helpers
source $BASH_UTILS_HOME/lib/scripting/general.bash

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Builds colcon @p packages residing in @var COLCON_SOURCE_DIR
#
# @param packages..
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
colbuild() {

    # Function's options
    declare -a defs=(
        '--up-to',up_to,f
        '-v',verbose,f
        '--fv',full_verbose,f
    )

    # Enable words-splitting locally
    local IFS
    enable_word_splitting

    # Parse options
    local -A options
    parseopts "$*" defs options posargs

    # Arguments
    local _packages_=("${posargs[@]}")

    # Get source directory
    local _src_dir_="${COLCON_SOURCE_DIR:-.}"

    # Set list of packages as positional arguments
    set -- "${_packages_[@]}"

    # Enable/disable logs
    is_var_set options[verbose] 

    # Set verbosity level
    local INIT_LOGS_STATE=$(get_stdout_logs_status)
    local verbose_compilation=0
    [[ options[full_verbose] -eq "1" || options[verbose] -eq "1" ]] && enable_stdout_logs || disable_stdout_logs
    [[ options[full_verbose] -eq "1"                             ]] && verbose_compilation=1
    
    # Check for dependencies
    [[ verbose_log == 1 ]] && log_info "ros" "Checking for dependencies"
    rosdep install -i --from-path src -y

    # Prepare bulding environments
    [[ $verbose_compilation == 1 ]] && export VERBOSE=1
    # Compile colcon flags
    local build_flags=''
    [[ $verbose_compilation == 1 ]] && build_flags="--event-handlers console_direct+"
    # Compile colcon build
    local build_type='--packages-select'
    is_var_set options[up_to] && build_type="--packages-up-to"

    # Log initial message
    log_info "ros" "Building package(s)"
    # If no packages' names given, build the whole directory
    if [[ $# -eq 0 ]]; then
        colcon build --base-paths "$_src_dir_" $build_flags
    # Else, build listed
    else 
        # Iterate over packages
        for package in "$@"; do
            
            # Build package
            if colcon build --base-paths "$_src_dir_" $build_type $package $build_flags; then

                log_error "ros" "Failed to build \'$package\' package"
                set_stdout_logs_status "$INIT_LOGS_STATE"
                return 1
                
            else
                log_info "ros" "\'$package\' package built"
            fi
            
        done
    fi

    # Restore logs state
    set_stdout_logs_status "$INIT_LOGS_STATE"
    
}

# -------------------------------------------------------------------
# @brief Reinitializes rosdep
# -------------------------------------------------------------------
reset_rosdep() {

    # Remove default configuration
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list

    # Initialize & update rosdep
    rosdep init && rosdep update

}
