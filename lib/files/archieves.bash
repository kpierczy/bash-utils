#!/usr/bin/env bash
# ====================================================================================================================================
# @file     archieves.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 7:11:57 pm
# @modified Tuesday, 9th November 2021 3:37:33 am
# @project  BashUtils
# @brief
#    
#    Set of tools related to archieve files
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source dependency
source $BASH_UTILS_HOME/lib/files/files.bash

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Writes extension of the archieve's @p filename to stdout
#
# @param filename
#    path to the archieve
# @returns
#    @c 0 on succes \n
#    @c 1 if @p filename is not a path to a known archieve file
#
# @note Supported archieves are:
#
#   .tar
#   .tgz (prints tar.gz)
#   .tbz (prints tar.bz2)
#   .txz (prints tar.xz)
#   .zip
#   .7z
#   .tar.gz
#   .tar.bz2
#   .tar.xz
#
# -------------------------------------------------------------------
get_archieve_extension() {

    # Arguments
    local filename_="$1"

    # Get extension of the archieve
    local extension_; extension_="$(get_file_extension "$filename_")" || return 1

    # Identify extension
    case "$extension_" in
    
        # Uncompressed tarballs
        tar ) echo "$extension_";;
        # Compressed tarballs
        tgz | tbz | txz ) 
        
            local -A extensions_map_=(
                [tgz]="tar.gz"
                [tbz]="tar.bz2"
                [txz]="tar.xz"
            )

            # Write out resolved extension
            echo "${extensions_map_[$extension_]}";;
            
        # Compressed entities
        zip | 7z ) echo "$extension_";;
        # Compressed tarballs
        gz | bz2 | xz )
            
            local preextension_

            # Try to extract '.tar' subextension from the filename
            preextension_="$(get_file_extension "$(remove_file_extension "$filename_")")" ||
                return 1

            # If '.tar' preextension parsed, return complete extension;
            if [[ "$preextension_" == "tar" ]]; then
                echo "tar.$extension_"
            # Else, return error
            else
                return 1
            fi

            ;;

        # Unknown extension
        *   ) return 1;;
        
    esac

}

# -------------------------------------------------------------------
# @brief Extracts content of the archieve file
#
# @param archieve
#    name of the archieve to be extracted; type of the archieve
#    is deduced from the name of the file
#
# @options
#
#    -l  
#
# @environment
#
#    ARCHIEVE_EXT  If set, determines type of the archieve. This
#                  can be used when an archieve is downloaded
#                  from the Internet and the default name of the
#                  file does not contains extention that could
#                  be used to deduce tool required for extracting
#                  files
#
# @note Function supports archieve types supported by @fun 
#    get_archieve_extension (@see get_archieve_extension)
# -------------------------------------------------------------------
extract_with_progress_bar() {
    pv "${@: -1}" | tar "${@:1:$#-1}"
}

# -------------------------------------------------------------------
# @brief Downloads @p url from the online server and extracts it's
#   content to @p dir directory performing decompression based on 
#   the @p url's extension
#
# @param url
#    URL to be downloaded
# @param ddir
#    directory where file should be downloaded
# @param edir
#    directory where file should be extracted
#
# @returns
#    @c 0 on success \n
#    @c 1 on error
#
# @options
#
#    -v  prints verbose log
#
# @environment
#
#        ARCH_NAME  name of the archieve after being downloaded (if not
#                   given, the name of the downloaded file is not given)
#       CURL_FLAGS  additional flags for curl
#      LOG_CONTEXT  log context to be used when -v option passed
#       LOG_TARGET  name of the target used in logs when -v option 
#                   passed
#   FORCE_DOWNLOAD  by default, function will skip download step, if
#                   a file with the same name as the target archieve
#                   already exist. To force new download set this
#                   variable to a non-empty value
# -------------------------------------------------------------------
download_and_extract() {

    # Arguments
    local url_
    local ddir_
    local edir_

    # Options
    local defs=(
        '-v',verbose,f
    )

    # Parsed options
    local -A options
    local -a posargs

    # Parse options
    local IFS
    enable_word_splitting
    parseopts "$*" defs options posargs

    # Set positional arguments
    set -- ${posargs[@]}

    # Parse arguments
    url_="$1"
    ddir_="$2"
    edir_="$3"

    # Enable/disable logs
    local INIT_LOGS_STATE=$(get_stdout_logs_status)
    is_var_set options[verbose] && enable_stdout_logs || disable_stdout_logs

    # Parse environment
    local CONTEXT_=${LOG_CONTEXT:-}
    local TARGET_=${LOG_TARGET:-"files"}

    # Prepare paths
    local ARCHIEVE_PATH_=$ddir_/$(basename $url_)
    is_var_set_non_empty ARCH_NAME && {
        ARCHIEVE_PATH_=$ddir_/$ARCH_NAME
        mv $ddir_/$(basename $url_) $ddir_/$ARCH_NAME
    }

    # Prepare curl
    local curl_flags="${CURL_FLAGS:-''} "
    local curl_flags="-L $url_ -o $ARCHIEVE_PATH_" 
    is_var_set options[verbose] || curl_flags+=" -s"

    log_info "$CONTEXT_" "Downloading $TARGET_ to $ddir_..."
    
    # Download URL
    if is_var_set_non_empty FORCE_DOWNLOAD || [[ ! -f "$ARCHIEVE_PATH_" ]] ; then
        curl $curl_flags || {
            log_error "$CONTEXT_" "Failed to download $TARGET_"
            set_stdout_logs_status "$INIT_LOGS_STATE"
            return 1    
        }
    fi
    
    log_info "$CONTEXT_" "${TARGET_^} downloaded"

    # Get archieve's extension
    local ext_=${ARCHIEVE_PATH_##*.}
    # Select a valid decompression flag
    local compression_flag_=''
    case "$ext_" in
        tar ) decompression_flag_='';;
        gz  ) decompression_flag_='-z';;
        bz2 ) decompression_flag_='-j';;
        *   )
            log_info "$CONTEXT_" "Unknown compression format ($ext_)"
            set_stdout_logs_status "$INIT_LOGS_STATE"
            return 1
    esac

    # Prepare tar flags
    local tar_flags="--directory="$edir_" -x $decompression_flag_"
    # Prepare extraction command
    local ext_cmd="tar $tar_flags -f $ARCHIEVE_PATH_"
    is_var_set options[verbose] && ext_cmd="extract_with_progress_bar $tar_flags $ARCHIEVE_PATH_"

    # Extract files
    log_info "$CONTEXT_" "Extracting $TARGET_ to $edir_ ..."
    $ext_cmd || {
        log_error "$CONTEXT_" "Failed to extract $TARGET_"
        set_stdout_logs_status "$INIT_LOGS_STATE"
        return 1
    }
    
    log_info "$CONTEXT_" "${TARGET_^} extracted"

    # Restore logs state
    set_stdout_logs_status "$INIT_LOGS_STATE"
    
}
