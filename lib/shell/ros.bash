#!/usr/bin/env bash
# ====================================================================================================================================
# @file     ros.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 11:27:25 pm
# @modified Thursday, 4th November 2021 12:01:27 am
# @project  Winder
# @brief
#    
#    Set of handy cmd-line-functions  related to the ROS (Robot Operating System)
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Get path to the librarie's home
LIB_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")/../.."

# Source logging helper
source $LIB_HOME/lib/logging/logging.bash
# Source general scripting helpers
source $LIB_HOME/lib/scripting/general.bash

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
#         -q  quites verbose logs
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
        '-q',quite,f
    )

    # Parse options
    local -A options
    parseopts "$*" defs options posargs

    # Arguments
    local _packages_=("${posargs[@]}")

    # Get source directory
    local _src_dir_="${COLCON_SOURCE_DIR:-.}"

    # Set list of packages as positional arguments
    set -- "${_packages_[@]}"

    # Check for dependencies
    is_var_set options[quite] || log_info "ros" "Checking for dependencies"
    rosdep install -i --from-path src --rosdistro foxy -y

    # Log initial message
    is_var_set options[quite] || log_info "ros" "Building package(s)"
    # If no packages' names given, build the whole directory
    if [[ $# -eq 0 ]]; then
        colcon build --base-paths "$_src_dir_"
    # Else, build listed
    else 
        # Iterate over packages
        for package in "$@"; do
            # If option set, build  'up-to' the package
            if is_var_set options[up_to]; then
                colcon build --base-paths "$_src_dir_" --packages-up-to $package;
            else
                colcon build --base-paths "$_src_dir_" --packages-select $package;
            fi
            # Log result
            if ! $?; then
                is_var_set options[quite] || log_error "ros" "Failed to build \'$package\' package"
                return 1
            else
                is_var_set options[quite] || log_info "ros" "\'$package\' package built"
            fi
        done
    fi

}
