#!/usr/bin/env bash
# ====================================================================================================================================
# @file     modifying.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:04:36 am
# @modified Sunday, 7th November 2021 6:42:55 pm
# @project  BashUtils
# @brief
#    
#    Set of handy functions related to files' manipulation
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Adds @p string to the @p file with an optional @p comment
#
# @p file
#    destination file
# @param string
#    string to be added to the file
# @param comment (optional)
#    comment descibing the @p string
# -------------------------------------------------------------------
add_to_file() {

    local dst=$1
    local string=$2
    local comment=$3

    # Append strin and comment (if passed)
    if [[ $# -gt 1 ]]; then
        echo "# $comment" >> $dst;
        echo "$string" >> $dst;
    else
        echo "$string" >> $dst;
    fi

    # End with an empty line
    echo "" >> $FILE;

}

# -------------------------------------------------------------------
# @brief Adds @p string as a new line to the ~/.bashrc if @p string
#    is not present. Additional @p comment can be written before
#    @c string
#
# @param string
#    string to be added to ~/.bashrc
# @param comment (optional)
#    comment descibing the @p string
# -------------------------------------------------------------------
add_to_bashrc() {

    local string=$1
    local comment=$2
    
    # Output file
    local FILE=~/.bashrc

    # Check if line is present in .bashrc
    if ! [[ -f $FILE ]] || ! grep "$string" $FILE > /dev/null; then

        add_to_file "$FILE" "$string" "$comment"

    fi
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


# -------------------------------------------------------------------
# @brief Prints extension of the archieve to stdout
#
# @param arch
#    path to the archieve
# @returns
#    @c 0 on succes \n
#    @c 1 if @p arch is not an archieve file
#
# @note Function returns a valid output for the following extension
#
#   .tar
#   .tar.gz
#   .tar.bz2
#   .zip
#   .7z
#
# -------------------------------------------------------------------
get_archieve_ext() {

    # Arguments
    local arch_=$1

    # Get extension of the archieve
    local ext_="${arch_##*.}"

    # Identify extension
    case $ext_ in
        # Compressed tarrbals
        gz | bz2 )
            
            # Remove compression type from archieve's name
            local arch_uncompressed_="${arch_%.$ext_}"

            # Get tarrbal extension
            local tar_ext_=${arch_uncompressed_##*.}

            # Identify extension
            case $tar_ext_ in
                tar ) echo "$tar_ext_.$ext_"; return 0;;
                *   ) return 1;;
            esac

            ;;

        # Tarrbals and zip/7z formats
        tar | zip | 7z )
            echo $ext_
            return
            ;;
        # Unknown extension
        *   ) return 1;;
    esac

}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Declares set of strings commonly used when downloading
#    archieve from the Internet
#
# @environment:
#
#              URL  URL of the archieve to be downloaded
#     DOWNLOAD_DIR  directory where the archieve will be downloaded
#
# @provides
#
#     ARCHIEVE_NAME  basename of the archieve file
#     ARCHIEVE_PATH  path to the archieve file after being downloaded
#      ARCHIEVE_EXT  extension of the archieve file
#    EXTRACTED_NAME  basename name of archieve with remove archieve
#                    extension
# 
# @note Alias declares all names as 'local'
# -------------------------------------------------------------------
alias prepare_names_for_downloaded_archieve='
# Archieve basename
local ARCHIEVE_NAME=$(basename $URL)
# Archieve path after being downloaded
local ARCHIEVE_PATH=$DOWNLOAD_DIR/$ARCHIEVE_NAME
# Extension of the archieve
local ARCHIEVE_EXT=$(get_archieve_ext $ARCHIEVE_NAME)
# Path to the extracted archieves files
local EXTRACTED_NAME="${ARCHIEVE_NAME%.$ARCHIEVE_EXT}"
'
