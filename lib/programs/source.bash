#!/usr/bin/env bash
# ====================================================================================================================================
# @file     source.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 9:36:34 pm
# @modified Sunday, 21st November 2021 10:16:47 pm
# @project  BashUtils
# @brief
#    
#    Set of tools related to building software from source
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Constants =========================================================== #

# -------------------------------------------------------------------
# @brief Names of marker files placed by the library in the build 
#    directory after completing corresponding step of the package 
#    build
# -------------------------------------------------------------------
declare -A TARGET_MARKERS=(
           [configure]=".configured"
               [build]=".built"
        [target_build]=".%s-built"
             [install]=".installed"
      [target_install]=".%s-installed"
)

# ======================================================== Helper functions ======================================================== #

# -------------------------------------------------------------------
# @brief Prints name of the marker corresponding to the marker
#    indicating that the build @p action performed in the 
#    @p build_dir for the @p target was succesfully completed
#
# @param build_dir 
#    build directory to be action
# @param action 
#    build action to be inspected (one of [configure, build, 
#    install])
# @param target (optional, default: '') 
#    build target to be inspected
# -------------------------------------------------------------------
function get_marker_name() {

    # Arguments
    local build_dir_="$1"
    local action_="$2"
    local target_="${3:-}"
    
    # Get marker pattern from the markers table
    local marker_="$build_dir_/${TARGET_MARKERS[$action_]}"
    # If targetted action given, resolve the marker pattern
    if [[ "$action_" == "built" || "$action_" == "installed" ]]; then
        marker_="$(printf "$marker_" "$target_")"
    fi

    # Print the marker's name
    echo $marker_

}

# -------------------------------------------------------------------
# @brief Marks @p build_dir directory with the @p action marker 
#
# @param build_dir 
#    build directory to be marked
# @param action 
#    action corresponding to the marker (one of [configure, build, 
#    install])
# @param target (optional) 
#    build target corresponding to the marker
# -------------------------------------------------------------------
function mark_directory() {

    # Arguments
    local build_dir_="$1"
    local action_="$2"
    local target_="${3:-}"

    # Get marker's name pattern from the markers table
    local marker_=$(get_marker_name "$build_dir_" "$action_" "$target_")
    # Create the marker
    [[ -f "$marker_" ]] || touch "$marker_"

}

# -------------------------------------------------------------------
# @brief Removes @p action marker from the @p build_dir directory 
#    if it exists
#
# @param build_dir 
#    build directory to be unmarked
# @param action 
#    action corresponding to the marker (one of [configure, build, 
#    install])
# @param target (optional) 
#    build target corresponding to the marker
# -------------------------------------------------------------------
function remove_directory_marker() {

    # Arguments
    local build_dir_="$1"
    local action_="$2"
    local target_="${3:-}"

    # Get marker's name pattern from the markers table
    local marker_=$(get_marker_name "$build_dir_" "$action_" "$target_")
    # Create the marker
    rm -f "$marker_"

}

# -------------------------------------------------------------------
# @brief Checks whether @p build_dir directory has been marked with
#    the @p action marker
#
# @param build_dir 
#    build directory to be inspected
# @param action 
#    action corresponding to the marker
# @param target (optional) 
#    build target corresponding to the marker
# -------------------------------------------------------------------
function is_directory_marked() {

    # Arguments
    local build_dir_="$1"
    local action_="$2"
    local target_="${3:-}"

    # Get marker's name pattern from the markers table
    local marker_=$(get_marker_name "$build_dir_" "$action_" "$target_")
    # Check if marker exists
    [[ -f "$marker_" ]]  

}

# -------------------------------------------------------------------
# @brief Checks whether the @p action is a valid build action
#
# @param action 
#    action to be inspected 
#
# @returns 
#    @c 0 if action is one of [configure, build, install] \n
#    @c 1 otherwise
# -------------------------------------------------------------------
function is_build_action() {

    # Arguments
    local action_="$1"

    # Check the action
    [[ "$action_" == "configure" ]] || 
    [[ "$action_" == "build"     ]] ||
    [[ "$action_" == "install"   ]] && 
        return 0 || return 1
        
}

# -------------------------------------------------------------------
# @brief Checks whether the @p action can be performed on a specific
#    target
#
# @param action 
#    action to be inspected (one of [configure, build, install])
#
# @returns 
#    @c 0 if action can be performed on the target \n
#    @c 1 if action cannot be performed on the target \n
#    @c 2 if invalid action given
#
# -------------------------------------------------------------------
function is_targeted_action() {

    # Arguments
    local action_="$1"

    # Check if valid action given
    is_build_action "$action_" || return 2

    # Check the action
    [[ "$action_" == "build" || "$action_" == "install" ]] && return 0 ||
    [[ "$action_" == "configure"                        ]] && return 1
    
}

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Performs a build action (configruation, building or 
#   installation) on the source files from @p src_dir_ directory
#
# @param action
#    build action to be performed (one of [configure, build, install])
# 
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if action was skipped
#
# @options
#
#    -s|--src-dir=DIR  source directory; applicable when the 
#                      'configure' action is performed (default: .)
#  -b|--build-dir=DIR  directory where the build action should
#                      be performed. Directory will be created if not
#                      exists (default: .)
#         -t|--target  name of the target; applies to the 
#                      build/install actions (default: '')
#           -m|--mark  if set, the successfull action will
#                      be marked by creating an empty '.configured'
#                      file in the build directory. If such a file
#                      is already present in the build directory,
#                      the function will return immediatelly unless
#                      --force option is specified
#          -f|--force  if set, function will perform an action
#                      without verifying either if the action has 
#                      already been sucesfully completed or if the
#                      preceding steps has been completed
#        -v|--verbose  if set, the building process will print
#                      verbose logs
#     --verbose-tools  if set, prints output of the tools used for
#                      action
#
# @environment
#
#         CONFIG_TOOL  name of the program/script residing in the 
#                      source directory performing configuration
#                      (default: configure)
#          BUILD_TOOL  name of the program/script used to build the
#                      source code (default: make)
#        INSTALL_TOOL  name of the program/script used to install the
#                      built source code (default: make install)
#        CONFIG_FLAGS  list containing flags passed to the 
#                      configuration tool
#         BUILD_FLAGS  list containing flags passed to the build tool
#       INSTALL_FLAGS  list containing flags passed to the 
#                      installation tool
#
# @environment (logging)
# 
#         LOG_CONTEXT  log context used when verbose configuration 
#                      requested
#           LOG_TABLE  hash table containing log messages printed
#                      on the subsequent steps of the action
#
#                         [INIT] message printed at the beginning
#                                of the action
#                      [SUCCESS] message printed after sucessfully 
#                                completed action
#                         [SKIP] message printed when skipping the
#                                action
#                     [REQ_FAIL] message printed when the action 
#                                cannot be performed due to unmet
#                                requirements (e.g. cannot build 
#                                with unconfigured build directory)
#                        [ERROR] message printed after error when 
#                                performing the action
#
# -------------------------------------------------------------------
function perform_build_action() {

    # Arguments
    local action_
    local src_dir_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-t|--target',target,
        '-s|--src-dir',src_dir
        '-b|--build-dir',build_dir
        '-m|--mark',mark,f
        '-f|--force',force,f
        '-v|--verbose',verbose,f
        '--verbose-tools',verbose_tools,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    action_="${posargs[0]}"
    
    # ----------------- Configure logs ----------------  

    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set options[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # -------- Prepare configuration environment ------

    # Check if valid action given
    is_build_action "$action_" || {
        log_error "Invalid build actin given ($action_)"
        restore_log_config_from_default_stack
        return 1
    }

    # Establish the builddir
    local build_dir_="${options[build_dir]:-.}"
    mkdir -p "$build_dir_"

    # Establish the action target
    local target_=''
    is_targeted_action "$action_" && is_var_set_non_empty options[target] &&
        target_="${options[target]}"

    # Establish configuration tool
    local action_tool_=''
    case "$action_" in
        configure ) action_tool_="${options[src_dir]:-.}/${CONFIG_TOOL:-configure}";;
        build     ) action_tool_="${BUILD_TOOL:-make}";;
        install   ) action_tool_="${INSTALL_TOOL:-make install}";;
    esac

    # Get action flags
    local action_flags_=''
    case "$action_" in
        configure ) action_flags_="${CONFIG_FLAGS[@]:-}";;
        build     ) action_flags_="${BUILD_FLAGS[@]:-}";;
        install   ) action_flags_="${INSTALL_FLAGS[@]:-}";;
    esac
    
    # ------ Check if action need to be performed -----

    # Change directory to the builddir
    pushd "${build_dir_}" > /dev/null

    # If no --force option passed, check whether action can/need to be performed
    is_var_set options[force] || {

        # Check if an action was aready sucesfully completed
        is_directory_marked "$build_dir_" "$action_" "$target_" && {

            is_var_set LOG_TABLE[SKIP] && log_info "${LOG_TABLE[SKIP]}"

            restore_log_config_from_default_stack
            popd > /dev/null
            return 2
        }
        
        # Check whether action can be performed
        case "$action_" in
            
            build )
            
                # Check if build directroy was already configured; if not, report error
                is_directory_marked "$build_dir_" "configure" || {

                    is_var_set LOG_TABLE[REQ_FAIL] && log_error "${LOG_TABLE[REQ_FAIL]}"

                    restore_log_config_from_default_stack
                    popd > /dev/null
                    return 1
                };;
                
            install   )
            
                # Check if build directroy was already built; if not, report error
                is_directory_marked "$build_dir_" "build" || 
                is_directory_marked "$build_dir_" "build" "$target_" || {

                    is_var_set LOG_TABLE[REQ_FAIL] && log_error "${LOG_TABLE[REQ_FAIL]}"

                    restore_log_config_from_default_stack
                    popd > /dev/null
                    return 1
                };;
                
        esac

    }

    # Unmark the directory if it was previously marked that the @p action was sucesfully completed
    remove_directory_marker "$build_dir_" "$action_" "$target_"

    # ------------ Enable word splitting -------------- 

    # Enable word-splitting (localy) to properly parse options
    localize_word_splitting
    enable_word_splitting

    # ---------------- Perform an action --------------

    is_var_set LOG_TABLE[INIT] && log_info "${LOG_TABLE[INIT]}"

    local ret_

    # Configure the build directory
    if is_var_set options[verbose_tools]; then
        $action_tool_ $target_ $action_flags_ && ret_=$? || ret_=$?
    else
        $action_tool_ $target_ $action_flags_ &> /dev/null && ret_=$? || ret_=$?
    fi
    
    # Check action's result
    [[  $ret_ == "0" ]] || {
        
        is_var_set LOG_TABLE[ERROR] && log_error "${LOG_TABLE[ERROR]}"

        restore_log_config_from_default_stack
        popd > /dev/null
        return 1
    }
    
    is_var_set LOG_TABLE[SUCCESS] && log_info "${LOG_TABLE[SUCCESS]}"

    # Mark build directory with the coresponding marker
    is_var_set options[mark] &&
        mark_directory "$build_dir_" "$action_" "$target_"
    
    restore_log_config_from_default_stack
    popd > /dev/null
    return 0

}

# -------------------------------------------------------------------
# @brief Builds source files fromsource directory to be built in the
#    build directory
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if action was skipped
#
# @options
#
#    -s|--src-dir=DIR  source directory (default: .)
#  -b|--build-dir=DIR  directory where the configuration should be
#                      performed. Directory will be created if not
#                      exists (default: .)
#           -m|--mark  if set, the successfull configuration will
#                      be marked by creating an empty '.configured'
#                      file in the build directory. If such a file
#                      is already present in the build directory,
#                      the function will return immediatelly unless
#                      --force option is specified
#          -f|--force  if set, function will configure source code
#                      even if the build directory was already marked
#                      as configured
#        -v|--verbose  if set, the configuration process will print
#                      verbose logs
#     --verbose-tools  if set, prints output of the tools used for
#                      configuration
#   --log-target=NAME  name of the target to be configured printed
#                      in the logs (if not given, the default logs
#                      will be printed based on the source and build
#                      directories)
#
# @environment
#
#         CONFIG_TOOL  name of the program/script residing in the 
#                      @p src_dir directory performing configuration
#                      (default: configure)
#        CONFIG_FLAGS  list containing flags passed to the 
#                      configuration app
#         LOG_CONTEXT  log context used when verbose configuration 
#                      requested
#
# -------------------------------------------------------------------
function configure_source() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--src-dir',src_dir
        '-b|--build-dir',build_dir
        '-v|--verbose',verbose,f
        '--verbose-tools',verbose_tools,f
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options
    
    # -------------- Prepare environment --------------  

    local action_flags_

    # Get source dir
    local src_dir_="${options[src_dir]:-.}"
    # Get build dir
    local build_dir_="${options[build_dir]:-.}"

    # Prepare obligratory flags
    action_flags_+="--src-dir=$src_dir_     "
    action_flags_+="--build-dir=$build_dir_ "
    # Prepare optional flags
    is_var_set options[verbose]       && action_flags_+="--verbose                           "
    is_var_set options[verbose_tools] && action_flags_+="--verbose-tools                     "
    is_var_set options[mark]          && action_flags_+="--mark                              "
    is_var_set options[force]         && action_flags_+="--force                             "
    is_var_set options[log_target]    && action_flags_+="--log-target=${options[log_target]} "

    # Targetted logs
    local -A TARGETTED_LOG_TABLE=(
           [INIT]="Configuring ${options[log_target]:-} ..."
        [SUCCESS]="Sucesfully configured ${options[log_target]:-}"
           [SKIP]="Skipping ${options[log_target]:-} build"
          [ERROR]="Failed to configure ${options[log_target]:-}"
    )

    # Default logs
    local -A DEFAULT_LOG_TABLE=(
           [INIT]="Configuring ${build_dir_} directory to build source files from ${src_dir_} ..."
        [SUCCESS]="Sucesfully configured ${build_dir_} directory"
           [SKIP]="Skipping configuration of the ${build_dir_} directory"
          [ERROR]="Failed to configure ${build_dir_} directory"
    )

    # Set an appropriate log table
    if is_var_set options[log_target]; then
        local -n LOG_TABLE=TARGETTED_LOG_TABLE
    else
        local -n LOG_TABLE=TARGETTED_LOG_TABLE
    fi

    # ------------ Enable word splitting -------------- 

    # Enable word-splitting (localy) to properly parse options
    localize_word_splitting
    enable_word_splitting

    # ------------------------------------------------- 
    
    # Perform configuration
    perform_build_action $action_flags_ "configure"

}

# -------------------------------------------------------------------
# @brief Builds source files configured in the build directory
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if action was skipped
#
# @options
#
#  -b|--build-dir=DIR  directory where the building should be
#                      performed. Directory will be created if not
#                      exists (default: .)
#         -t|--target  name of the target to be built
#           -m|--mark  if set, the successfull building will
#                      be marked by the function. If such a marker
#                      is already present, the function will return
#                      immediatelly unless --force option is 
#                      specified
#          -f|--force  if set, function will try to build source code
#                      either even if the build directory wasn't marked
#                      as configured or even if it was marked as already
#                      built
#        -v|--verbose  if set, the building process will print
#                      verbose logs
#     --verbose-tools  if set, prints output of the tools used for
#                      building
#   --log-target=NAME  name of the target to be built printed
#                      in the logs (if not given, the default logs
#                      will be printed based on the build
#                      directory)
#
# @environment
#
#          BUILD_TOOL  name of the tool performing building
#                      (default: make)
#         BUILD_FLAGS  list containing flags passed to the 
#                      build tool
#         LOG_CONTEXT  log context used when verbose building 
#                      requested
#
# -------------------------------------------------------------------
function build_source() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-b|--build-dir',build_dir
        '-t|--target',target
        '-v|--verbose',verbose,f
        '--verbose-tools',verbose_tools,f
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------- Prepare environment --------------  

    local action_flags_

    # Get build dir
    local build_dir_="${options[build_dir]:-.}"

    # Prepare obligratory flags
    action_flags_+="--build-dir=$build_dir_ "
    # Prepare optional flags
    is_var_set options[target]        && action_flags_+="--target=${options[target]}         "
    is_var_set options[verbose]       && action_flags_+="--verbose                           "
    is_var_set options[verbose_tools] && action_flags_+="--verbose-tools                     "
    is_var_set options[mark]          && action_flags_+="--mark                              "
    is_var_set options[force]         && action_flags_+="--force                             "
    is_var_set options[log_target]    && action_flags_+="--log-target=${options[log_target]} "

    # Targetted logs
    local -A TARGETTED_LOG_TABLE=(
              [INIT]="Building ${options[log_target]:-} ..."
           [SUCCESS]="Sucesfully build ${options[log_target]:-}"
              [SKIP]="Skipping ${options[log_target]:-} build"
             [ERROR]="Failed to build ${options[log_target]:-}"
          [REQ_FAIL]="Cannot build ${options[log_target]:-} as the build directory has not been configured"
    )

    # Default logs
    local -A DEFAULT_LOG_TABLE=(
           [INIT]="Building ${build_dir_} directory ..."
        [SUCCESS]="Sucesfully build ${build_dir_} directory"
           [SKIP]="Skipping bilding of the ${build_dir_} directory"
          [ERROR]="Failed to build ${build_dir_} directory"
          [REQ_FAIL]="Cannot build as the ${options[log_target]:-} directory has not been configured"
    )

    # Set an appropriate log table
    if is_var_set options[log_target]; then
        local -n LOG_TABLE=TARGETTED_LOG_TABLE
    else
        local -n LOG_TABLE=TARGETTED_LOG_TABLE
    fi

    # ------------ Enable word splitting -------------- 

    # Enable word-splitting (localy) to properly parse options
    localize_word_splitting
    enable_word_splitting

    # ------------------------------------------------- 
    
    # Perform building
    perform_build_action $action_flags_ "build" 
    
}

# -------------------------------------------------------------------
# @brief Installs targets built in the build directory
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if action was skipped
#
# @options
#
#  -b|--build-dir=DIR  directory where the isntallation should be
#                      performed. Directory will be created if not
#                      exists (default: .)
#         -t|--target  name of the target to be installed
#           -m|--mark  if set, the successfull installation will
#                      be marked by the function. If such a marker
#                      is already present, the function will return
#                      immediatelly unless --force option is 
#                      specified
#          -f|--force  if set, function will try to install target(s)
#                      either even if the build directory wasn't marked
#                      as built or even if it was marked as already
#                      isntalled
#        -v|--verbose  if set, the installation process will print
#                      verbose logs
#     --verbose-tools  if set, prints output of the tools used for
#                      isntallation
#   --log-target=NAME  name of the target to be built printed
#                      in the logs (if not given, the default logs
#                      will be printed based on the build
#                      directory)
#
# @environment
#
#        INSTALL_TOOL  name of the tool performing installation
#                      (default: make install)
#       INSTALL_FLAGS  list containing flags passed to the 
#                      installation tool
#         LOG_CONTEXT  log context used when verbose installation 
#                      requested
#
# -------------------------------------------------------------------
function install_source() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-b|--build-dir',build_dir
        '-t|--target',target
        '-v|--verbose',verbose,f
        '--verbose-tools',verbose_tools,f
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------- Prepare environment --------------  

    local action_flags_

    # Get build dir
    local build_dir_="${options[build_dir]:-.}"

    # Prepare obligratory flags
    action_flags_+="--build-dir=$build_dir_ "
    # Prepare optional flags
    is_var_set options[target]        && action_flags_+="--target=${options[target]}         "
    is_var_set options[verbose]       && action_flags_+="--verbose                           "
    is_var_set options[verbose_tools] && action_flags_+="--verbose-tools                     "
    is_var_set options[mark]          && action_flags_+="--mark                              "
    is_var_set options[force]         && action_flags_+="--force                             "
    is_var_set options[log_target]    && action_flags_+="--log-target=${options[log_target]} "

    # Targetted logs
    local -A TARGETTED_LOG_TABLE=(
           [INIT]="Installing ${options[log_target]:-} ..."
        [SUCCESS]="Sucesfully installed ${options[log_target]:-}"
           [SKIP]="Skipping installation of the ${options[log_target]:-}"
          [ERROR]="Failed to install ${options[log_target]:-}"
          [REQ_FAIL]="Cannot install ${options[log_target]:-} as the build directory has not been build"
    )

    # Default logs
    local -A DEFAULT_LOG_TABLE=(
           [INIT]="Installing ${build_dir_} directory ..."
        [SUCCESS]="Sucesfully installed ${build_dir_} directory"
           [SKIP]="Skipping installation of the ${build_dir_} directory"
          [ERROR]="Failed to install ${build_dir_} directory"
          [REQ_FAIL]="Cannot install as the ${options[log_target]:-} directory has not been built"
    )

    # Set an appropriate log table
    if is_var_set options[log_target]; then
        local -n LOG_TABLE=TARGETTED_LOG_TABLE
    else
        local -n LOG_TABLE=TARGETTED_LOG_TABLE
    fi

    # ------------ Enable word splitting -------------- 

    # Enable word-splitting (localy) to properly parse options
    localize_word_splitting
    enable_word_splitting

    # ------------------------------------------------- 

    # Perform isntallation
    perform_build_action $action_flags_ "install"

}

# -------------------------------------------------------------------
# @brief Configures, builds and installs built targets from the 
#    @p src_dir directory. Building process is performed in the 
#    @p build_dir directory
# 
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if action was skipped
#
# @options
#
#    -s|--src-dir=DIR  source directory (default: .)
#  -b|--build-dir=DIR  directory where the configuration should be
#                      performed. Directory will be created if not
#                      exists (default: .)
#         -t|--target  name of the target to be built and installed
#           -m|--mark  if set, the successfull subsequent step will
#                      be marked by the function. If such a marker
#                      is already present, the corresponding step 
#                      will be skipped unless --force option is 
#                      specified
#          -f|--force  if set, function will perform all building
#                      steps no matter if some of them could be 
#                      skipped
#        -v|--verbose  if set, the building process will print
#                      verbose logs
#     --verbose-tools  if set, prints output of the tools used for
#                      configuration, building and isntallation
#   --log-target=NAME  name of the target to be built printed
#                      in the logs (if not given, the default logs
#                      will be printed based on the build
#                      directory)
#         --up-to=STR  if given, function conducts stepd only up to the
#                      STR (can be one of [configure, compile, install])
#
# @environment
#
#         CONFIG_TOOL  name of the program/script residing in the 
#                      @p src_dir directory performing configuration
#                      (default: configure)
#          BUILD_TOOL  name of the program/script used to build the
#                      source code (default: make)
#        INSTALL_TOOL  name of the program/script used to install the
#                      built source code (default: make install)
#        CONFIG_FLAGS  list containing flags passed to the 
#                      configuration tool
#         BUILD_FLAGS  list containing flags passed to the build tool
#       INSTALL_FLAGS  list containing flags passed to the 
#                      installation tool
#         LOG_CONTEXT  log context used when verbose configuration 
#                      requested
#
# -------------------------------------------------------------------
function build_and_install() {

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-s|--src-dir',src_dir
        '-b|--build-dir',build_dir
        '-t|--target',target
        '-v|--verbose',verbose,f
        '--verbose-tools',verbose_tools,f
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
        '--up-to',up_to
    )
    
    # Parse arguments to a named array
    parse_options

    local ret_

    # -------------- Prepare environment --------------  

    # Get build dir
    local build_dir_="${options[build_dir]:-.}"
    # Get source dir
    local src_dir_="${options[src_dir]:-.}"

    # Prepare configuration flags
    local config_flags_=''
    is_var_set options[src_dir]       && config_flags_+="--src-dir=$src_dir_                 "
    is_var_set options[build_dir]     && config_flags_+="--build-dir=$build_dir_             "
    is_var_set options[verbose]       && config_flags_+="--verbose                           "
    is_var_set options[verbose_tools] && config_flags_+="--verbose-tools                     "
    is_var_set options[mark]          && config_flags_+="--mark                              "
    is_var_set options[force]         && config_flags_+="--force                             "
    is_var_set options[log_target]    && config_flags_+="--log-target=${options[log_target]} "

    # Prepare build flags
    local build_flags_=''
    is_var_set options[build_dir]     && build_flags_+="--build-dir=$build_dir_             "
    is_var_set options[target]        && build_flags_+="--target=${options[target]}         "
    is_var_set options[verbose]       && build_flags_+="--verbose                           "
    is_var_set options[verbose_tools] && build_flags_+="--verbose-tools                     "
    is_var_set options[mark]          && build_flags_+="--mark                              "
    is_var_set options[force]         && build_flags_+="--force                             "
    is_var_set options[log_target]    && build_flags_+="--log-target=${options[log_target]} "

    # Prepare installation flags
    local install_flags_=''
    is_var_set options[build_dir]     && install_flags_+="--build-dir=$build_dir_             "
    is_var_set options[target]        && install_flags_+="--target=${options[target]}         "
    is_var_set options[verbose]       && install_flags_+="--verbose                           "
    is_var_set options[verbose_tools] && install_flags_+="--verbose-tools                     "
    is_var_set options[mark]          && install_flags_+="--mark                              "
    is_var_set options[force]         && install_flags_+="--force                             "
    is_var_set options[log_target]    && install_flags_+="--log-target=${options[log_target]} "

    # Set target
    local target_=''
    is_var_set options[target] &&
        target_="${options[target]}"

    # Assume, that all steps will be skipped
    local all_skipped_=1

    # ------------ Enable word splitting -------------- 

    # Enable word-splitting (localy) to properly parse options
    localize_word_splitting
    enable_word_splitting

    # ------------------- Configure -------------------
    
    # Perform configuration
    configure_source $config_flags_ && ret_=$? || ret_=$?
    
    # If error occurred, exit
    [[ "$ret_" == "1" ]] && return 1
    # If a new configuration was performed, mark the folder as not-built and not-installed
    [[ "$ret_" == "0" ]] && {
        remove_directory_marker "$build_dir_" "build" "$target_"
        remove_directory_marker "$build_dir_" "install"   "$target_"
        all_skipped_=0
    }

    # If up-to 'configure' defined, return success
    if is_var_set_non_empty options[up_to]; then
        [[ "${options[up_to]}" == "configure" ]] && return 0
    fi

    # --------------------- Build ---------------------

    # Perform building
    build_source $build_flags_ && ret_=$? || ret_=$?
    # If erro occurred, exit
    [[ "$ret_" == "1" ]] && return 1
    # If a new configuration was performed, mark the folder as not-installed
    [[ "$ret_" == "0" ]] && {
        remove_directory_marker "$build_dir_" "install" "$target_"
        all_skipped_=0
    }

    # If up-to 'build' defined, return success
    if is_var_set_non_empty options[up_to]; then
        [[ "${options[up_to]}" == "build" ]] && return 0
    fi

    # -------------------- Install --------------------
    
    # Perform installation
    install_source $install_flags_ && ret_=$? || ret_=$?
    # If erro occurred, exit
    [[ "$ret_" == "1" ]] && return 1
    # Update information about skipping all steps
    [[ "$ret_" == "0" ]] && all_skipped_=0

    # Return status code
    [[ "$all_skipped_" == "1" ]] && return 2 || return 0

}

# -------------------------------------------------------------------
# @brief A wombo-combo function that downloads an archieve 
#    containing source code, builds it and installs on the system
#
# @param url 
#    URL to the  archieve to be downloaded
#
# @returns 
#    @c 0 on success \n
#    @c 1 if all steps were skipped \n
#    @c 2 on error
#
# @options
#     
#         -v|--verbose  prints verbose logs describing the download,
#                       extraction, build and isntallation process
#      --verbose-tools  if set, prints output of the tools used for
#                       configuration, building and isntallation
#       --arch-dir=DIR  directory where the archive will be downloaded
#                       (default: '.')
#     --arch-path=PATH  path to the archieve after being downloaded; if 
#                       given, overwrites --archdir option (by default,
#                       name of the downloaded archieve is not modified)
#    --extract-dir=DIR  directory where the archieve will be extracted;
#                       will be created, if needed
#   -p|--show-progress  displays progress bars when downloading and
#                       extracting
#           -f|--force  by default, function checks whether subsequent
#                       steps are required (i.e. if the archieve is
#                       already downloaded and extracted and whether
#                       some parts of the build process has been already
#                       completed). If so, it skips part that was already
#                       accomplished. If --force flag is set, this
#                       behaviout is abandoned and the whole process
#                       is conducted
#    -s|--src-dir=DIR  source directory; by default, function assumes
#                      that the source directory is the same as the 
#                      extraction directory. In most cases, the archieve
#                      contains not directly source files, but the 
#                      directory gathering all files. This option can
#                      be passed to point to this directory (relative
#                      to the extraction directory
#  -b|--build-dir=DIR  directory where the build process should be
#                      performed. Directory will be created if not
#                      exists (default: .)
#         -t|--target  name of the target to be built and installed
#           -m|--mark  if set, the successfull subsequent build steps
#                       will be marked by the function. If such a marker
#                      is already present, the corresponding step 
#                      will be skipped unless --force option is 
#                      specified
#   --log-target=NAME  name of the target to be built printed
#                      in the logs (if not given, the default logs
#                      will be printed based on the build
#                      directory)
#         --up-to=STR  if given, function conducts stepd only up to the
#                      STR (can be one of [download, configure, compile,
#                      install])
#
# @environment
#
#         LOG_CONTEXT  log context to be used when -v option passed
#          WGET_FLAGS  additional flags for wget command (overwrites
#                      flags passed by the function)
#         CONFIG_TOOL  name of the program/script residing in the 
#                      @p src_dir directory performing configuration
#                      (default: configure)
#          BUILD_TOOL  name of the program/script used to build the
#                      source code (default: make)
#        INSTALL_TOOL  name of the program/script used to install the
#                      built source code (default: make install)
#        CONFIG_FLAGS  list containing flags passed to the 
#                      configuration tool
#         BUILD_FLAGS  list containing flags passed to the build tool
#       INSTALL_FLAGS  list containing flags passed to the 
#                      installation tool
#
# -------------------------------------------------------------------
function download_build_and_install() {

    # Arguments
    local url_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
        '--verbose-tools',verbose_tools,f
        '--arch-dir',arch_dir,
        '--arch-path',arch_path,
        '--extract-dir',extract_dir,
        '-p|--show-progress',progress,f
        '-f|--force',force,f
        '-s|--src-dir',src_dir
        '-b|--build-dir',build_dir
        '-t|--target',target
        '-m|--mark',mark,f
        '--log-target',log_target
        '--up-to',up_to
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    url_="${posargs[0]}"

    # Assume that all steps will be skipped
    local all_skipped_=1
    # Return status
    local ret_

    # ---------- Prepare common environment -----------

    # Establish whether verbose logs should be displayed
    local verbose_flag_=''
    is_var_set options[verbose] &&
        verbose_flag_="--verbose"

    # Establish whether all steps should be forced
    local force_flag_=''
    is_var_set options[force] &&
        force_flag_="--force"

    # Establish whether a specific log target should be used
    local log_target_=''
    is_var_set options[log_target] &&
        log_target_="--log-target=${options[log_target]}"

    # --- Prepare download & extraction environment ---

    # Establish whether progress bar should be displayed
    local download_extract_progess_flag_=''
    is_var_set options[verbose] &&
        download_extract_progess_flag_="--show-progress"

    # Establish download directory
    local download_extract_destination_opt_=''
    is_var_set options[arch_dir] &&
        download_extract_destination_opt_="--arch-dir=${options[arch_dir]}"
    is_var_set options[arch_path] &&
        download_extract_destination_opt_="--arch-path=${options[arch_path]}"

    # Establish extraction directory
    local download_extract_extract_dir_=''
    is_var_set options[extract_dir] &&
        download_extract_extract_dir_="--extract-dir=${options[extract_dir]}"

    # Compile dowload/extract flags
    local download_extract_all_flags_=$(echo   \
        "${verbose_flag_}"                     \
        "${force_flag_}"                       \
        "${log_target_}"                       \
        "${download_extract_progess_flag_}"    \
        "${download_extract_destination_opt_}" \
        "${download_extract_extract_dir_}"
    )

    # ------------ Prepare build environment ---------- 

    # Establish whether verbose tools' logs should be displayed
    local build_verbose_tools_flag_=''
    is_var_set options[verbose_tools] &&
        build_verbose_tools_flag_="--verbose-tools"

    # Establish source directory
    local build_source_dir_="--src-dir=${options[extract_dir]:-.}"
    is_var_set options[src_dir] &&
        build_source_dir_="--src-dir=${options[extract_dir]:-.}/${options[src_dir]}"    

    # Establish build directory
    local build_build_dir_="."
    is_var_set options[build_dir] &&
        build_build_dir_="--build-dir=${options[build_dir]}"    

    # Establish build target
    local build_target_=""
    is_var_set options[target] &&
        build_target_="--target=${options[target]}"    

    # Establish whether build steps should be marked
    local build_mark_flag_="."
    is_var_set options[mark] &&
        build_mark_flag_="--mark"

    # Establish whether steps performed by the function are limited
    local up_to_flag=''
    is_var_set_non_empty options[up_to] && 
        up_to_flag="${options[up_to]}"

    # Compile build flags
    local build_all_flags_=$(echo      \
        "${verbose_flag_}"             \
        "${build_verbose_tools_flag_}" \
        "${force_flag_}"               \
        "${log_target_}"               \
        "${build_source_dir_}"         \
        "${build_build_dir_}"          \
        "${build_target_}"             \
        "${build_mark_flag_}"          \
        "${up_to_flag}"
    )

    # ------------ Enable word splitting -------------- 

    # Enable word-splitting (localy) to properly parse options
    localize_word_splitting
    enable_word_splitting

    # --------- Download and extract sources ---------- 
    
    # Try to download and extract sources
    download_and_extract ${download_extract_all_flags_[@]} $url_ && ret_=$? || ret_=$?

    # If error occurred, return error
    [[ $ret_ == "1" ]] && return 1

    # If downloading and/or extraction wasn't skipped, mark it
    [[ $ret_ != "2" ]] && all_skipped_=0

    # If up-to 'download' defined, return success
    if is_var_set_non_empty options[up_to]; then
        [[ "${options[up_to]}" == "download" ]] && return 0
    fi

    # ---------------- Build sources ------------------ 

    # Try to build and install sources
    build_and_install $build_all_flags_ && ret_=$? || ret_=$?
    
    # If error occurred, return error
    [[ $ret_ == "1" ]] && return 1

    # If downloading and/or extraction wasn't skipped, mark it
    [[ $ret_ != "2" ]] && all_skipped_=0

    # Return status code
    [[ $all_skipped_ == "1" ]] && return 2 || return 0
    
}
