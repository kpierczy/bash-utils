#!/usr/bin/env bash
# ====================================================================================================================================
# @file     archieves.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 7:11:57 pm
# @modified Wednesday, 10th November 2021 7:01:25 pm
# @project  BashUtils
# @brief
#    
#    Set of tools related to archieve files
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependencies
source $BASH_UTILS_HOME/lib/scripting/options.bash
source $BASH_UTILS_HOME/lib/scripting/settings.bash

# ============================================================ Constant ============================================================ #

# Dictionary of supported archieves formats paired with space-separated lists of corresponding files extensions
declare -A BASHLIB_SUPPORTED_ARCHIEVES=(
    ["tar.gz"]="tgz tar.gz"
   ["tar.bz2"]="tbz tar.bz2"
    ["tar.xz"]="txz tar.xz"
       ["tar"]="tar"
       ["zip"]="zip"
)

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Checks whether @p format is a supported archieve format
# 
# @param format
#    archieve format to be verified
#
# @returns 
#    @c 0 if @p format is a supported archieve format \n
#    @c 1 otherwise
# -------------------------------------------------------------------
function is_compatibile_archieve_format() {

    # Arguments
    local format_="$1"

    # Get array of dictionaries' keys
    local -a supported_formats_=( "${!BASHLIB_SUPPORTED_ARCHIEVES[@]}" )
    
    # Iterate over valid formats
    is_array_element supported_formats_ "$format_"

}

# -------------------------------------------------------------------
# @brief Checks whether @p extension is a supported archieve
#    extension
# 
# @param extension
#    archieve extension to be verified
#
# @returns 
#    @c 0 if @p extension is a supported archieve extension \n
#    @c 1 otherwise
# -------------------------------------------------------------------
function is_compatibile_archieve_extension() {

    # Arguments
    local extension_="$1"

    # Enable words-splitting (localy)
    limit_word_splitting_settings
    enable_word_splitting

    # Flatten values of the dictionary holding <supported_format:corresponding extensions> pairs
    # to an array of supported extensions by breaking dictionarie's values on '[:space:]' 
    # (thanks to auto word-splitting)
    local -a supported_extensions_=( ${BASHLIB_SUPPORTED_ARCHIEVES[@]} )
    
    # Iterate over valid formats
    is_array_element supported_extensions_ "$extension_"

}

# -------------------------------------------------------------------
# @brief Writes extension of the archieve's @p filename to stdout
#
# @param filename
#    path to the archieve
# @returns
#    @c 0 on succes \n
#    @c 1 if @p filename is not a path to a known archieve file
#
# @note List of supported archieves extension with their 
#    corresponding return strings is hold in 
#    @var BASHLIB_SUPPORTED_ARCHIEVES hash array
# -------------------------------------------------------------------
function get_archieve_format() {

    # Arguments
    local filename_="$1"

    # Enable words-splitting (localy)
    limit_word_splitting_settings
    enable_word_splitting

    # Make iterators local
    local format_
    local extension_

    # Iterate over dictionary of supported archieves' formats
    for format_ in "${!BASHLIB_SUPPORTED_ARCHIEVES[@]}"; do

        # Iterate over extensions corresponding to the format
        for extension_ in ${BASHLIB_SUPPORTED_ARCHIEVES[$format_]}; do

            # If @p filename ends with @var extension, return corresponding format
            ends_with "$filename_" ".$extension_" && {
                echo "$format_"
                return 0
            }

        done

    done

    return 1

}

# -------------------------------------------------------------------
# @brief Extracts content of the archieve file
#
# @param archieve
#    name of the archieve to be extracted; type of the archieve
#    is deduced from the name of the file
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error
#
# @options
#
#      -v  --verbose  a progress bar will be printed during 
#                     extraction
#    --directory=dir  content of the archieve will be extracted
#                     to the dir directory
#           --format If set, determines format of the archieve 
#                    eliminating automatic format detection based
#                    on the @p archieve's extension. This can be 
#                    used when an archieve is downloaded from the 
#                    Internet and the default name of the file does
#                    not contains extention that could be used to
#                    deduce tool required for extracting files
#
# @note List of supported archieves extension with their 
#    corresponding return string are hold in 
#    @var BASHLIB_SUPPORTED_ARCHIEVES hash array
# -------------------------------------------------------------------
function extract_archieve() {

    # Arguments
    local archieve_

    # ----------------- Configuration -----------------
    
    # Commands used to extract archieves of specified formats
    local -A EXTRACTION_COMMANDS_=(
            [tar]="tar xf        %s %s"
         [tar.gz]="tar xzf       %s %s"
        [tar.bz2]="tar xjf       %s %s"
         [tar.xz]="tar xJf       %s %s"
            [zip]="busybox unzip %s %s"
             [7z]="7z x          %s %s"
    )
    
    # Commands used to extract archieves of specified formats in verbose mode
    # (7z extraction does not work with pipe input for some reason)
    local -A EXTRACTION_COMMANDS_VERBOSE_=(
            [tar]="tar x"
         [tar.gz]="tar xz"
        [tar.bz2]="tar xj"
         [tar.xz]="tar xJ"
            [zip]="busybox unzip -"
             [7z]="7z x -t7z -si" 
    )
    
    # Commands modiefier used to extract archieve to a specified directory
    # (@ note: \055 is an octal code of the '-'; it is used to not let
    # `printf` call interpret values of the following table as it's own option)
    local -A EXTRACTION_COMMANDS_DIR_MOD_=(
            [tar]="\055C %s"
         [tar.gz]="\055C %s"
        [tar.bz2]="\055C %s"
         [tar.xz]="\055C %s"
            [zip]="\055d %s"
             [7z]="\055o %s"
    )

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
        '--directory',dir
        '--format',format
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    local archieve_="${posargs[0]}"

    # -------------------------------------------------

    # Local variables
    local format_
    local cmd_

    # Try to parse format from options
    if is_var_set options[format]; then

        # If a valid format given, parse it
        is_compatibile_archieve_format "${options[format]}" &&
            format_="${options[format]}"

    # Else, try to deduce archieve format from archieve's extension
    else
        format_=$(get_archieve_format $archieve_) || return 1
    fi
    
    # Prepare directory modifier, if given
    local dir_mod_=''
    is_var_set options[dir] && 
        dir_mod_="$(printf "${EXTRACTION_COMMANDS_DIR_MOD_[$format_]}" "${options[dir]}")"

    # Prepare command to be used to extract archieve
    if is_var_set options[verbose]; then
        cmd_="${EXTRACTION_COMMANDS_VERBOSE_[$format_]} "$dir_mod_""
    else
        cmd_="$(printf "${EXTRACTION_COMMANDS_[$format_]}" "$archieve_" "$dir_mod_")"
    fi

    # Extract archieve
    if is_var_set options[verbose]; then
        pv "$archieve_" | $cmd_ > /dev/null || return 1
    else
        $cmd_ > /dev/null || return 1
    fi

}

# -------------------------------------------------------------------
# @brief Downloads an archieve file from the @p url online server 
#   and extracts it's content 
#
# @param url
#    URL to be downloaded
# @returns
#    @c 0 on success \n
#    @c 1 on error
#
# @options
#
#        --arch-dir  directory where the archive will be downloaded
#                    (default: '.')
#       --arch-path  path to the archieve after being downloaded; if 
#                    given, overwrites --archdir option (by default,
#                    name of the downloaded archieve is not modified)
#     --arch-format  format of the downloaded directory ( @see 
#                    BASHLIB_SUPPORTED_ARCHIEVES ). By default, 
#                    function tries to deduce format of the archieves
#                    from the --arch-path (if given) or the default
#                    name of the downloaded file (if not)
#     --extract-dir  directory where the archieve will be extracted
#                -p  displays progress bars when downloading and when
#                    extracting
#                -v  prints verbose logs; passes --no-verbose flag
#                    to the `wget` (@note output of the download
#                    and extract tools like `wget` (except progress
#                    bars) are forced silence)
#  --force-download  forced download of the archieve even if the 
#                    target file already exists (by default, function
#                    will skip download step, if a file already 
#                    exist)
#
# @environment
#
#       LOG_CONTEXT  log context to be used when -v option passed
#        LOG_TARGET  name of the target used in logs when -v option 
#                    passed
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
        '--arch-format',arch_format
        '--extract-dir',extr_dir
        '-p',progress,f
        '-v',verbose,f
        '--force-download',force_download,f
    )
    
    # Parse arguments to a named array
    parse_options
    
    # Parse arguments
    url_="${posargs[0]}"

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
    ! is_var_set options[force_download] &&
        wget_force_download_flag_="--no-clobber"

    # Compile wget flags
    local wget_all_flags_=$(echo       \
        "${wget_destination_opt_}"     \
        "${wget_progess_flag_}"        \
        "${wget_verboseness_flag_}"    \
        "${wget_force_download_flag_}" \
        "${WGET_FLAGS:-}"
    )

    # --------------- Download archieve ---------------  

    # Prepare log target
    local ltarget_="${LOG_TARGET:-archieve}"

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
    
    # Download URL
    archieve_path_=$(wget_and_localize $wget_all_flags_ $url_) || {

        # Log error
        log_error "Failed to download ${ltarget_}"
        # Restore logging settings
        restore_log_config_from_default_stack
        # Return error
        return 1

    }

    log_info "${ltarget_^} downloaded"

    # Check if the downloaded file reside under the assumed path
    [[ -f "$archieve_path_" ]] || {
        
        # Log error
        log_error "Downloaded archieve could not be fund under assummed path ($archieve_path_). " \
                  "The most probable reason is that name could not be deduced from the given URL" \
                  "due to redirections. Please retry with --arch-path option. "
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

    # Establish archieve format
    local extract_format_opt_=''
    is_var_set options[arch_format] &&
        extract_format_opt_="--format=${options[arch_format]}"

    # Compile extraction flags
    local extract_all_flags_=$(echo  \
        "${extract_progress_flag_}"  \
        "${extract_directory_opt_}"  \
        "${extract_format_opt_}"  
    )

    # ---------------- Extract archieve ---------------

    # Prepare log target
    local ltarget_="${LOG_TARGET:-files}"

    # Get extraction directory
    local extract_dir_='.'
    is_var_set options[extr_dir] &&
        extract_dir_=${options[extr_dir]}
    # Create extraction dir
    mkdir -p "$extract_dir_"

    log_info "Extracting ${ltarget_} to $(realpath ${extract_dir_}) ..."

    # Extract files
    extract_archieve $extract_all_flags_ $archieve_path_ || {

        # Log error
        log_error "Failed to extract "
        # Restore logging settings
        restore_log_config_from_default_stack
        # Return error
        return 1
        
    }
    
    log_info "${ltarget_^} extracted"

    # Restore logging settings
    restore_log_config_from_default_stack
    
}
