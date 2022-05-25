#!/usr/bin/env bash
# ====================================================================================================================================
# @file       ros.bash
# @author     Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @maintainer Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date       Wednesday, 3rd November 2021 11:27:25 pm
# @modified   Wednesday, 25th May 2022 1:19:35 pm
# @project    Winder
# @brief
#    
#    Set of handy cmd-line-functions  related to the ROS (Robot Operating System)
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ======================================================== Helper functions ======================================================== #

# -------------------------------------------------------------------
# @brief Perofrms colcon action on given @p packages residing in
#    @var COLCON_SOURCE_DIR
#
# @param command
#    colcon cmd to be run
# @param success_msg
#    verb printed on action success
# @param failure_msg
#    verb printed on action failure
# @param options_and_packages...
#    list of packages to be built; if no @p packages are given, the 
#    whole @var COLCON_SOURCE_DIR dirctory is built as well as list
#    of options
# 
# @options 
# 
#           --up-to  build packages with --packages-up-to flag 
#                    (instead of --packages-select)
#                -v  verbose logs
#              --fv  full verbosity (logs + buildtool commands)
#  -s|--source-each  if set, function will source local_setup.bash 
#                    file of each pakcage directly after it is 
#                    built
#
# @environment
#
#    @var COLCON_SOURCE_DIR (path)
#       source directory of packages to be built (default: .)
#    @var COLCON_FLAGS
#       additional flags to be passed to colcon
#    @var COLCON_ACTION_FLAGS
#       additional flags to be passed to colcon build
#
# @todo test
# -------------------------------------------------------------------
function colcon_wrapper() {

    # Arguments
    local command="$1"
    local success_msg="$2"
    local failure_msg="$3"

    # ---------------- Parse arguments ----------------

    # Set list of packages as positional arguments
    set -- "${@:4}"

    # Function's options
    declare -a opt_definitions=(
        '--up-to',up_to,f
        '-v',verbose,f
        '--fv',full_verbose,f
        '--with-flags',with_flags
        '-s|--source-each',source_each,f
    )

    # Parse arguments to a named array
    parse_options_s

    # Set list of packages as positional arguments
    set -- "${posargs[@]}"

    # Parse positional arguments
    local -a packages=( "$@" )
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
    local colcon_verbose=0
    is_var_set options[full_verbose] &&
        colcon_verbose=1

    # If additional flags given, parse them
    is_var_set COLCON_BUILD_FLAGS &&
        build_flags_+="$COLCON_BUILD_FLAGS"

    # ----------- Prepare build environment -----------

    # Check for dependencies
    log_info "Checking for dependencies"
    rosdep install -i --from-path $src_dir_ -y

    log_info "Runinng colcon ..."

    # If no packages' names given, build the whole directory
    if [[ $# -eq 0 ]]; then

        if ! VERBOSE=$colcon_verbose colcon $COLCON_FLAGS $command --base-paths $src_dir_ $build_flags_; then
            log_error "Failed to $failure_msg source directory"
            restore_log_config_from_default_stack
            return 1
        else
            log_info "Packages has ben sucesfully $success_msg"
        fi
        
    # Else, build listed packages
    else 

        local package_
        
        # Iterate over packages
        for package_ in "${packages[@]}"; do
            
            # Build package
            if ! VERBOSE=$colcon_verbose colcon $COLCON_FLAGS $command --base-paths $src_dir_ $build_type_ $package_ $build_flags_; then
                log_error "Failed to $failure_msg '$package_' package"
                restore_log_config_from_default_stack
                return 1
            # If sucesfully built
            else

                log_info "'$package_' package $success_msg"

                # Source package's settings, if requested
                if is_var_set options[source_each]; then
                    source "./install/$package_/share/$package_/local_setup.bash"
                fi

            fi
            
        done
    fi

    # Restore logs state
    restore_log_config_from_default_stack
}

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
#            --up-to  build packages with --packages-up-to flag 
#                     (instead of --packages-select)
#                 -v  verbose logs
#               --fv  full verbosity (logs + buildtool commands)
#  -s|--source-each  if set, function will source local_setup.bash 
#                    file of each pakcage directly after it is 
#                    built
#
# @environment
#
#    @var COLCON_SOURCE_DIR (path)
#       source directory of packages to be built (default: .)
#    @var COLCON_FLAGS
#       additional flags to be passed to colcon
#    @var COLCON_BUILD_FLAGS
#       additional flags to be passed to colcon build
#
# @todo test
# -------------------------------------------------------------------
function colbuild() {
    COLCON_ACTION_FLAGS="$COLCON_BUILD_FLAGS" \
    colcon_wrapper                            \
        "build"                               \
        "built"                               \
        "build"                               \
        "$@"
}

# -------------------------------------------------------------------
# @brief Tests colcon @p packages residing in @var COLCON_SOURCE_DIR
#
# @param packages...
#    list of packages to be tested; if no @p packages are given, the 
#    whole @var COLCON_SOURCE_DIR dirctory is tested
# 
# @options 
# 
#       --up-to  test packages with --packages-up-to flag (instead of 
#                --packages-select)
#            -v  verbose logs
#          --fv  full verbosity (logs + compiller commands)
#
# @environment
#
#    @var COLCON_SOURCE_DIR (path)
#       source directory of packages to be tested (default: .)
#    @var COLCON_FLAGS
#       additional flags to be passed to colcon
#    @var COLCON_TEST_FLAGS
#       additional flags to be passed to colcon test
#
# @todo test
# -------------------------------------------------------------------
function coltest() {
    COLCON_ACTION_FLAGS="$COLCON_TEST_FLAGS" \
    colcon_wrapper                           \
        "test"                               \
        "tested"                             \
        "test"                               \
        "$@"
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
