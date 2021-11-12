#!/usr/bin/env bash
# ====================================================================================================================================
# @file     source.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 9:36:34 pm
# @modified Friday, 12th November 2021 2:28:26 am
# @project  BashUtils
# @brief
#    
#    Set of tools related to building fostware from source
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
          [configured]=".configured",
               [built]=".built",
        [target_built]=".%s-built",
           [installed]=".installed",
    [target_installed]=".%s-installed",
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
#    build action to be inspected (one of [configured, built, 
#    installed])
# @param target (optional, default: '') 
#    build target to be inspected
# -------------------------------------------------------------------
function get_marker_name() {

    # Arguments
    local build_dir_="$1"
    local action_="$2"
    local target_="${3:-}"

    # Get marker pattern from the markers table
    local marker_="$build_dir_/${TARGET_MARKERS[action_]}"
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
#    action corresponding to the marker
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
    touch "$marker_"

}

# -------------------------------------------------------------------
# @brief Removes @p action marker from the @p build_dir directory 
#    if it exists
#
# @param build_dir 
#    build directory to be unmarked
# @param action 
#    action corresponding to the marker
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
#        -v|--verbose  if set, the configuration process will be
#                      verbose
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
        '-b|--build-dir=DIR',build_dir
        '-m|--mark',mark,f
        '-f|--force',force,f
        '-v|--verbose',verbose,f
        '--log-target=NAME',log_target
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
    if_build_action "$action_" || {
        log_error "Invalid build actin given ($action_)"
        restore_log_config_from_default_stack
        return 1
    }

    # Establish the builddir
    local build_dir_="${options[build_dir]:-.}"
    mkdir -p "$build_dir_"

    # Establish whether output of the action tool should be silenced
    local output_redirection_='&> /dev/null'
    is_var_set options[verbose] &&
        output_redirection_=''

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
    
    # ------------ Configure the source code ----------

    # Change directory to the builddir
    pushd "${build_dir_}"

    # If no --force option passed, check whether action can/need to be performed
    is_var_set options[force] || {

        # Check if an action was aready sucesfully completed
        is_directory_marked "$build_dir_" "$action_" "$target_" || {
            restore_log_config_from_default_stack
            popd
            return 2
        }

        # Check whether action can be performed
        case "$action_" in
            
            build )
            
                is_directory_marked "$build_dir_" "configured" || {
                    restore_log_config_from_default_stack
                    popd
                    return 1
                };;
                
            install   )
            
                is_directory_marked "$build_dir_" "built"            ||
                is_directory_marked "$build_dir_" "built" "$target_" || {
                    restore_log_config_from_default_stack
                    popd
                    return 1
                };;
                
        esac

    }

    # Unmark the directory if it was previously marked that the @p action was sucesfully completed
    remove_directory_marker "$build_dir_" "$action_" "$target_"

    is_var_set LOG_TABLE[INIT] && log_info "${LOG_TABLE[INIT]}"

    # Configure the build directory
    "$action_tool_" "$target_" "$action_flags_" "$output_redirection_" || {

        is_var_set LOG_TABLE[ERROR] && log_info "${LOG_TABLE[ERROR]}"

        restore_log_config_from_default_stack
        popd        
        return 1
    }

    is_var_set LOG_TABLE[SUCCESS] && log_info "${LOG_TABLE[SUCCESS]}"

    # Mark build directory with the coresponding marker
    is_var_set options[mark] &&
        mark_directory "$build_dir_" "$action_" "$target_"

    restore_log_config_from_default_stack
    popd
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
#        -v|--verbose  if set, the configuration process will be
#                      verbose
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
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------- Prepare environment --------------  

    local action_flags_

    # Prepare obligratory flags
    action_flags_+="--src-dir=${options[src_dir]:-.}     "
    action_flags_+="--build-dir=${options[build_dir]:-.} "
    # Prepare optional flags
    is_var_set options[verbose] && action_flags_+="--verbose "
    is_var_set options[mark]    && action_flags_+="--mark    "
    is_var_set options[force]   && action_flags_+="--force   "

    # Targetted logs
    declare -A TARGETTED_LOG_TABLE=(
           [INIT_LOG]="Configuring ${options[log_target]:-} ..."
        [SUCCESS_LOG]="Failed to configure ${options[log_target]:-}"
          [ERROR_LOG]="Sucesfully configured ${options[log_target]:-}"
    )

    # Default logs
    declare -A DEFAULT_LOG_TABLE=(
           [INIT_LOG]="Configuring ${build_dir_} directory to build source files from ${src_dir_} ..."
        [SUCCESS_LOG]="Failed to configure ${build_dir_} directory"
          [ERROR_LOG]="Sucesfully configured ${build_dir_} directory"
    )

    # Set an appropriate log table
    if is_var_set options[log_target]; then
        declare -n LOG_TABLE=TARGETTED_LOG_TABLE
    else
        declare -n LOG_TABLE=TARGETTED_LOG_TABLE
    fi

    # Perform configuration
    perform_build_action "$action_flags_" "configure"

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
#        -v|--verbose  if set, the building process will be verbose
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
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------- Prepare environment --------------  

    local action_flags_

    # Prepare obligratory flags
    action_flags_+="--build-dir=${options[build_dir]:-.} "
    # Prepare optional flags
    is_var_set options[target]  && action_flags_+="--target=${options[target]} "
    is_var_set options[verbose] && action_flags_+="--verbose                   "
    is_var_set options[mark]    && action_flags_+="--mark                      "
    is_var_set options[force]   && action_flags_+="--force                     "

    # Targetted logs
    declare -A TARGETTED_LOG_TABLE=(
           [INIT_LOG]="Building ${options[log_target]:-} ..."
        [SUCCESS_LOG]="Failed to build ${options[log_target]:-}"
          [ERROR_LOG]="Sucesfully build ${options[log_target]:-}"
    )

    # Default logs
    declare -A DEFAULT_LOG_TABLE=(
           [INIT_LOG]="building ${build_dir_} directory ..."
        [SUCCESS_LOG]="Failed to build ${build_dir_} directory"
          [ERROR_LOG]="Sucesfully build ${build_dir_} directory"
    )

    # Set an appropriate log table
    if is_var_set options[log_target]; then
        declare -n LOG_TABLE=TARGETTED_LOG_TABLE
    else
        declare -n LOG_TABLE=TARGETTED_LOG_TABLE
    fi

    # Perform building
    perform_build_action "$action_flags_" "build"

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
#        -v|--verbose  if set, the building process will be verbose
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
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target=NAME',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------- Prepare environment --------------  

    local action_flags_

    # Prepare obligratory flags
    action_flags_+="--build-dir=${options[build_dir]:-.} "
    # Prepare optional flags
    is_var_set options[target]  && action_flags_+="--target=${options[target]} "
    is_var_set options[verbose] && action_flags_+="--verbose                   "
    is_var_set options[mark]    && action_flags_+="--mark                      "
    is_var_set options[force]   && action_flags_+="--force                     "

    # Targetted logs
    declare -A TARGETTED_LOG_TABLE=(
           [INIT_LOG]="Installing ${options[log_target]:-} ..."
        [SUCCESS_LOG]="Failed to install ${options[log_target]:-}"
          [ERROR_LOG]="Sucesfully install ${options[log_target]:-}"
    )

    # Default logs
    declare -A DEFAULT_LOG_TABLE=(
           [INIT_LOG]="Installing ${build_dir_} directory ..."
        [SUCCESS_LOG]="Failed to install ${build_dir_} directory"
          [ERROR_LOG]="Sucesfully install ${build_dir_} directory"
    )

    # Set an appropriate log table
    if is_var_set options[log_target]; then
        declare -n LOG_TABLE=TARGETTED_LOG_TABLE
    else
        declare -n LOG_TABLE=TARGETTED_LOG_TABLE
    fi

    # Perform isntallation
    perform_build_action "$action_flags_" "install"

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
#        -v|--verbose  if set, the building process will be verbose
#   --log-target=NAME  name of the target to be built printed
#                      in the logs (if not given, the default logs
#                      will be printed based on the build
#                      directory)
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
        '-m|--mark',mark,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options

    # -------------- Prepare environment --------------  

    # Prepare configuration flags
    local config_flags_=''
    is_var_set options[verbose]    && config_flags_+="--verbose                           "
    is_var_set options[mark]       && config_flags_+="--mark                              "
    is_var_set options[force]      && config_flags_+="--force                             "
    is_var_set options[log_target] && config_flags_+="--log-target=${options[log_target]} "

    # Prepare build flags
    local build_flags_=''
    is_var_set options[target]     && config_flags_+="--target=${options[target]}         "
    is_var_set options[verbose]    && config_flags_+="--verbose                           "
    is_var_set options[mark]       && config_flags_+="--mark                              "
    is_var_set options[force]      && config_flags_+="--force                             "
    is_var_set options[log_target] && config_flags_+="--log-target=${options[log_target]} "

    # Prepare installation flags
    local install_flags_=''
    is_var_set options[target]     && config_flags_+="--target=${options[target]}         "
    is_var_set options[verbose]    && config_flags_+="--verbose                           "
    is_var_set options[mark]       && config_flags_+="--mark                              "
    is_var_set options[force]      && config_flags_+="--force                             "
    is_var_set options[log_target] && config_flags_+="--log-target=${options[log_target]} "

    # Set target
    local target_=''
    is_var_set options[target] &&
        target_="${options[target]}"

    # Assume, that all steps will be skipped
    local all_skipped_=1

    # ---------------- Build & install ----------------

    local ret_

    # Perform configuration
    configure_source "$config_flags_" "${options[src_dir_]:-.}" "${options[build_dir]:-.}" & ret_=$? || ret_=$?
    # If error occurred, exit
    [[ "$ret_" == "2" ]] && return 1
    # If a new configuration was performed, mark the folder as not-built and not-installed
    [[ "$ret_" == "1" ]] && {
        remove_directory_marker "${options[build_dir]:-.}" "configure" "$target_"
        remove_directory_marker "${options[build_dir]:-.}" "install"   "$target_"
    } || all_skipped_=0

    # Perform building
    build_source "$build_flags_" "${options[build_dir]:-.}"
    # If erro occurred, exit
    [[ "$ret_" == "2" ]] && return 1
    # If a new configuration was performed, mark the folder as not-installed
    [[ "$ret_" == "1" ]] && {
        remove_directory_marker "${options[build_dir]:-.}" "install" "$target_"
    } || all_skipped_=0

    # Perform installation
    install_source "$install_flags_" "${options[build_dir]:-.}"
    # If erro occurred, exit
    [[ "$ret_" == "2" ]] && return 1
    # Update information about skipping all steps
    [[ "$ret_" == "1" ]] || all_skipped_=0

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
#       --arch-dir=DIR  directory where the archive will be downloaded
#                       (default: '.')
#      --arch-path=DIR  path to the archieve after being downloaded; if 
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
function download_buil_and_install() {

    # Arguments
    local url_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
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

    # Establish source directory
    local build_source_dir_="--src-dir=${options[extract_dir]:-.}"
    is_var_set options[src_dir] &&
        build_source_dir_="--src-dir=${options[src_dir]}"    

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
    is_var_set options[target] &&
        build_mark_flag_="--mark"
    
    # Compile build flags
    local build_all_flags_=$(echo \
        "${verbose_flag_}"        \
        "${force_flag_}"          \
        "${log_target_}"          \
        "${build_source_dir_}"    \
        "${build_build_dir_}"     \
        "${build_target_}"        \
        "${build_mark_flag_}"
    )

    # --------- Download and extract sources ---------- 

    # Try to download and extract sources
    download_and_extract $download_extract_all_flags_ $url_ && ret_=$? || ret_=$?

    # If error occurred, return error
    [[ $ret_ == "1" ]] && return 1

    # If downloading and/or extraction wasn't skipped, mark it
    [[ $ret_ != "2" ]] && all_skipped_=0

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
