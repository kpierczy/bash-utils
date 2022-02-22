#!/usr/bin/env bash
# ====================================================================================================================================
# @file     archieves.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 7:11:57 pm
# @modified Monday, 21st February 2022 6:58:11 pm
# @project  bash-utils
# @brief
#    
#    Set of tools related to archieve files
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependencies
source $BASH_UTILS_HOME/lib/files/archieves/tar.bash
source $BASH_UTILS_HOME/lib/files/archieves/zip.bash
source $BASH_UTILS_HOME/lib/scripting/parseargs/short/parseopts.bash
source $BASH_UTILS_HOME/lib/scripting/settings.bash

# ============================================================ Constant ============================================================ #

# List of supported archieves formats
declare -a BASH_UTILS_SUPPORTED_ARCHIEVES=(
    "tar.gz"
    "tar.bz2"
    "tar.xz"
    "tar"
    "zip"
)

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Checks whether @p format is a supported archieve format
# 
# @param format
#    archieve format to be verified
#
# @returns 
#    @retval @c 0 if @p format is a supported archieve format 
#    @retval @c 1 otherwise
# -------------------------------------------------------------------
function is_compatibile_archieve_format() {

    # Arguments
    local format_="$1"
    
    # Iterate over valid formats
    is_array_element BASH_UTILS_SUPPORTED_ARCHIEVES "$format_"

}

# -------------------------------------------------------------------
# @brief Writes format of the archieve's @p filename to stdout
#
# @param filename
#    path to the archieve
#
# @returns
#    @retval @c 0 on succes 
#    @retval @c 1 if @p filename is not a path to a archieve file of the
#       known file
#
# @note List of supported archieves formats is hold in 
#    @var BASH_UTILS_SUPPORTED_ARCHIEVES hash array
# -------------------------------------------------------------------
function get_archieve_format() {

    # Arguments
    local filename_="$1"

    # Check if file exists
    [[ -f "$filename_" ]] || return 1

    # Enable word splitting (locally) to parse output of the `file` command into array
    localize_word_splitting
    IFS=$' \t\n,'
    # Inspect format of the file with the `file` application
    local -a file_desc_arr_
    file_desc_arr_=( $(file --brief $filename_ ) ) || return 1

    # Extract first three keys of the description
    local file_desc_="$(echo ${file_desc_arr_[@]:0:3})"

    # Hash array pairing supported formats with file's description
    declare -A supported_arch_desc_=(
            ["POSIX tar archive"]="tar"
        ["bzip2 compressed data"]="tar.bz2"
         ["gzip compressed data"]="tar.gz"
           ["XZ compressed data"]="tar.xz"
             ["Zip archive data"]="zip"
    )

    # Write out format based on the file's description
    local file_format_=${supported_arch_desc_["$file_desc_"]:-}

    # Check, if file is a supported archieve
    is_var_set_non_empty file_format_ || return 1

    # Print file's format
    echo "$file_format_"
    
    return 0
}

# -------------------------------------------------------------------
# @brief Creates archieve of the supported format
#
# @param format
#    format of the target archieve (on of values listed in the
#    @var BASH_UTILS_SUPPORTED_ARCHIEVES array)
# @param name
#    name of the target archieve
# @param files...
#    files to be added to the archieve
#
# @returns
#    @retval @c 0 on success 
#    @retval @c 1 on error or if the unsupported archieve format was given
#
# @options
#
#     -v|--verbose  prints output of the underlying archive tool
#                   too the stdout
#
# @environment
#  
#   ARCHIEVE_FLAGS  list containing flags to be passed to the tool
#                   creating an archieve
#
# -------------------------------------------------------------------
function create_archieve() {

    # Arguments
    local format_
    local name_
    local files_
    
    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
    )
    
    # Parse arguments to a named array
    parse_options_s

    # Parse arguments
    format_="${posargs[0]}"
    name_="${posargs[1]}"
    files_=( "${posargs[@]:2}" )

    # -------------------------------------------------
    
    # Check if a supported format given
    is_compatibile_archieve_format "$format_" || return 1
    # Select tool
    local cmd_=''
    local options_=''
    case "$format_" in
        "tar.gz"  ) cmd_="tar"; options_="czf" ;;
        "tar.bz2" ) cmd_="tar"; options_="cjf" ;;
        "tar.xz"  ) cmd_="tar"; options_="cJf" ;;
        "tar"     ) cmd_="tar"; options_="cf"  ;;
        "zip"     ) cmd_="zip"                 ;;
    esac

    # Enable wor splitting (locally) to properly parse command's arguments
    localize_word_splitting
    enable_word_splitting

    # Get archieve's flags
    local flags_="${ARCHIEVE_FLAGS[*]:-}"

    # Compile the whole command
    cmd_="$cmd_ $flags_ $options_ $name_ ${files_[@]}"

    # Create an chieve
    if is_var_set options[verbose]; then
        $cmd_ || return 1
    else
        $cmd_ &> /dev/null || return 1
    fi
    
    return 0
}

# -------------------------------------------------------------------
# @brief Checks whether the archieve named @p archieve was already
#    extracted to the directory
#
# @param archieve
#    name of the archieve file to be inspected
#
# @returns
#   @c 0 if archieve wasn't already extracted \n
#   @c 1 on error \n
#   @c 2 if archieve was already extracted
#
# @options
#
#    -d|--directory  extraction directory that should be compared
#                    with the content of an archieve (default: .)
#   
# -------------------------------------------------------------------
function need_extract() {

    # Arguments
    local archieve_
    
    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-d|--directory',dir
    )
    
    # Parse arguments to a named array
    parse_options_s

    # Parse arguments
    archieve_="${posargs[0]}"

    # Parse options
    local dir_="${options[dir]:-.}"

    # -------------------------------------------------

    local format_

    # Check if file is a supported archieve type
    format_=$(get_archieve_format $archieve_) || return 1

    # Check if directory exists
    [[ -d "${dir_}" ]] || return 0
    
    # Select an appropriate test basing on the file's format
    case "$format_" in

        # Tarballs
        "tar.gz"  | "tar.bz2" |  "tar.xz"  |  "tar" ) 

            local ret_

            # @note comparison fails if files differ with respect to UID and GID
            # @fixme

            # Compare directory and archieve
            tar --compare --file="$archieve_" --directory="$dir_" &> /dev/null && ret_=$? || ret_=$?
            
            # Return status code
            [[ $ret_ == "0" ]] && return 2 ||
            [[ $ret_ == "1" ]] && return 0 ||
                                  return 1;;

        # ZIP archieves (parsing by hand...)
        "zip" ) 
            
            need_zip_extract --directory="$dir_" "$archieve_"

    esac

}

# -------------------------------------------------------------------
# @brief Extracts content of the archieve file
#
# @param archieve
#    name of the archieve to be extracted
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 on error 
#    @retval @c 2 if archieve was already extracted
#
# @options
#
#       -v  --verbose  a progress bar will be printed during 
#                      extraction
#  -d|--directory=dir  content of the archieve will be extracted
#                      to the dir directory
#          -f|--force  extracts directory even if content of the
#                      extraction directory matches content of the
#                      archieve
#
# @note List of supported archieves extension is held in 
#    @var BASH_UTILS_SUPPORTED_ARCHIEVES array
# -------------------------------------------------------------------
function extract_archieve() {

    # Arguments
    local archieve_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
        '-d|--directory',dir
        '-f|--force',force,f
    )
    
    # Parse arguments to a named array
    parse_options_s

    # Parse arguments
    local archieve_="${posargs[0]}"

    # -------------------------------------------------

    # Local variables
    local format_
    local cmd_

    # Get archieve's format    
    format_=$(get_archieve_format $archieve_) || return 1
    
    # Prepare directory modifier, if given
    local verbose_flag=''
    is_var_set options[verbose] &&
        verbose_flag='-v'

    # ------ Check if archieve already extracted ------
    
    # Check if extraction was forced by option
    is_var_set options[force] || {
        
        local ret_
        # Check if archieve would be extracted despite no differences in the source
        need_extract --directory="${options[dir]:-.}" "$archieve_" && ret_=$? || ret_=$?
        # If so, return (or return an error)
        [[ $ret_ == "0" ]] || return $ret_

    }

    # --------------- Extract archieve ----------------

    # Select tool for extraction
    local tool_="extract_${format_%.*}_archieve"
    
    # Extract archieve
    ${tool_} $verbose_flag --directory="${options[dir]:-.}" "$archieve_"

}

# -------------------------------------------------------------------
# @brief Downloads an archieve file from the @p url online server 
#   and extracts it's content. If the archieve is already downloaded,
#   this step is skipped. The same concenrs extraction step
#
# @param url
#    URL to be downloaded
#
# @returns
#    @retval @c 0 on success 
#    @retval @c 1 on error 
#    @retval @c 2 if both download and extraction steps were skipped
#
# @options
#
#           --arch-dir  directory where the archive will be downloaded
#                       (default: '.')
#          --arch-path  path to the archieve after being downloaded; if 
#                       given, overwrites --archdir option (by default,
#                       name of the downloaded archieve is not modified)
#        --extract-dir  directory where the archieve will be extracted;
#                       will be created, if needed
#   -p|--show-progress  displays progress bars when downloading and when
#                       extracting
#         -v|--verbose  prints verbose logs; passes --no-verbose flag
#                       to the `wget` (@note output of the download
#                       and extract tools like `wget` (except progress
#                       bars) are forced silence)
#           -f|--force  forced download of the archieve even if the 
#                       target file already exists (by default, function
#                       will skip download step, if a file already 
#                       exist). By default, dontent of the archieve
#                       is compared with the extraction directory and
#                       extraction step is performed only if both 
#                       differs. -f flag forces extraction.
#    --log-target=NAME  name of the target used in logs when -v option 
#                       passed
#
# @environment
#
#       LOG_CONTEXT  log context to be used when -v option passed
#        WGET_FLAGS  additional flags for wget command (overwrites
#                    flags passed by the function)
#  
# @note If destination directories for downloaded archieve or 
#    extracted files does not exist, they will be created
# -------------------------------------------------------------------
function download_and_extract() {

    # Arguments
    local url_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '--arch-dir',arch_dir
        '--arch-path',arch_path
        '--extract-dir',extr_dir
        '-p|--show-progress',progress,f
        '-v|--verbose',verbose,f
        '-f|--force',force,f
        '--log-target',log_target
    )
    
    # Parse arguments to a named array
    parse_options_s
    
    # Parse arguments
    url_="${posargs[0]}"

    # Assume that both steps will be skipped
    local all_skipped_=1

    # ----------------- Configure logs ----------------   

    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set options[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # ------------ Prepare download flags ------------   

    # Establish output flags
    local wget_destination_opt_=''
    is_var_set options[arch_dir] &&
        wget_destination_opt_="--directory-prefix=${options[arch_dir]}"
    is_var_set options[arch_path] &&
        wget_destination_opt_="--output-document=${options[arch_path]}"
    
    # Establish whether progress bar should be displayed
    local wget_progess_flag_=''
    is_var_set options[progress] &&
        wget_progess_flag_="--show-progress"

    # Establish whether archieve should be redownloaded
    local wget_force_download_flag_=''
    ! is_var_set options[force] &&
        wget_force_download_flag_="--no-clobber"

    # Compile wget flags
    local wget_all_flags_=$(echo       \
        "${wget_destination_opt_}"     \
        "${wget_progess_flag_}"        \
        "${wget_force_download_flag_}" \
        "${WGET_FLAGS:-}"
    )
    
    # --------------- Download archieve ---------------  

    # Prepare log target
    local ltarget_="${options[log_target]:-archieve}"

    # Establish download directory
    local download_dir='.'
    is_var_set options[arch_dir] &&
        download_dir="${options[arch_dir]}" 
    is_var_set options[arch_path] &&
        download_dir="$(dirname ${options[arch_path]})"
    # Create download dir
    mkdir -p "$download_dir"
    
    log_info "Downloading ${ltarget_} to $(realpath "${download_dir}") ..."

    # Establish path to the downloaded archieve
    local archieve_path_=''
    
    # Enable word-splitting (locally) to properly parse wget's arguments
    localize_word_splitting
    enable_word_splitting
    
    local ret_

    # Download URL
    archieve_path_=$(wget_and_localize $wget_all_flags_ $url_)  && ret_=$? || ret_=$?
    
    # Check if error occurred
    [[ "$ret_" != "1" ]] || {

        # Log error
        log_error "Failed to download ${ltarget_}"
        # Restore logging settings
        restore_log_config_from_default_stack
        # Return error
        return 1

    }
    
    [[ "$ret_" == "0" ]] &&
        log_info "${ltarget_^} downloaded" ||
        log_info "Skipping ${ltarget_} download..." 

    # If download step was not skipped, mark it
    [[ "$ret_" != "0" ]] || all_skipped_=0
    
    # Check if the downloaded file reside under the assumed path
    # (should not heppen with a new implementation of `wget_and_localize`)
    [[ -f "$archieve_path_" ]] || {
        
        # Log error
        log_error "Downloaded archieve could not be found under assummed path ($archieve_path_). " \
                  "The most probable reason is that name could not be deduced from the given URL" \
                  "due to redirections. Please retry with --arch-path option. "
        log_error "This error should not heppen with a new implementation of `wget_and_localize`" \
                  "Please report an error"
        # Restore logging settings
        restore_log_config_from_default_stack
        # Return error
        return 1

    }
    
    # ------------ Prepare extraction flags -----------

    # Establish whether progress bar should be displayed
    local extract_progress_flag_=''
    is_var_set options[progress] &&
        extract_progress_flag_="--verbose"

    # Establish extraction directory
    local extract_directory_opt_=''
    is_var_set options[extr_dir] &&
        extract_directory_opt_="--directory=${options[extr_dir]}"

    # Establish whether extraction should be forces
    local extract_force_flag_=''
    if is_var_set options[force] || [[ "$all_skipped_" != 1 ]]; then
        extract_force_flag_='--force'
    fi

    # Compile extraction flags
    local extract_all_flags_=$(echo \
        "${extract_progress_flag_}" \
        "${extract_directory_opt_}" \
        "${extract_force_flag_}"
    )

    # ---------------- Extract archieve ---------------

    # Prepare log target
    local ltarget_="${options[log_target]:-files}"

    # Get extraction directory
    local extract_dir_='.'
    is_var_set options[extr_dir] &&
        extract_dir_=${options[extr_dir]}
    # Create extraction dir
    mkdir -p "$extract_dir_"

    log_info "Extracting ${ltarget_} to $(realpath ${extract_dir_}) ..."

    # Extract files
    extract_archieve $extract_all_flags_ $archieve_path_ && ret_=$? || ret_=$?

    # Check if error ocurred
    [[ "$ret_" != "1" ]] || {

        # Log error
        log_error "Failed to extract "
        # Restore logging settings
        restore_log_config_from_default_stack
        # Return error
        return 1
        
    }
    
    [[ "$ret_" == "0" ]] &&
        log_info "${ltarget_^} extracted" ||
        log_info "Skipping ${ltarget_} extraction..." 
    

    # If extraction step was not skipped, mark it
    [[ "$ret_" != "0" ]] || all_skipped_=0

    # Restore logging settings
    restore_log_config_from_default_stack

    # Restore status code
    [[ "$all_skipped_" == "1" ]] && return 2 || return 0
    
}
