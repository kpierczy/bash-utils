#!/usr/bin/env bash
# ====================================================================================================================================
# @file     zip.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 11th November 2021 9:27:03 pm
# @modified Monday, 21st February 2022 6:58:11 pm
# @project  bash-utils
# @brief
#    
#    Set of tools related to ZIP archieves
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Checks whether the ZIP archieve named @p archieve was 
#    already extracted to the directory
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
function need_zip_extract() {

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

    local ARCH_MOUNT_POINT_="/tmp/zip_mount"

    # Check if destination directory exists
    [[ -d "${dir_}" ]] || return 0

    # Create a mount point for ZIP archieve
    mkdir "$ARCH_MOUNT_POINT_" || return 1
    
    # Mount zipfile in the temporary directory (read only mode)
    fuse-zip -r  "$archieve_" "$ARCH_MOUNT_POINT_" || {
        rmdir "$ARCH_MOUNT_POINT_"
        return 1
    }
    
    local ret_

    # Check difference between directories
    diff --recursive --brief --from-file="${dir_}" "${ARCH_MOUNT_POINT_}" &> /dev/null && ret_=2 || ret_=0
    
    # Unmount the archieve
    umount "$ARCH_MOUNT_POINT_" || {
        log_error "Error: could not umount directory at $ARCH_MOUNT_POINT_"
        rmdir "$ARCH_MOUNT_POINT_"
        return 1
    }
    # Remove mount point
    rmdir "$ARCH_MOUNT_POINT_"

    return $ret_

}

# -------------------------------------------------------------------
# @brief Extracts content of the ZIP archieve file
#
# @param archieve
#    name of the archieve to be extracted
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 on error 
#
# @options
#
#       -v  --verbose  a progress bar will be printed during 
#                      extraction
#  -d|--directory=dir  content of the archieve will be extracted
#                      to the dir directory
#
# -------------------------------------------------------------------
function extract_zip_archieve() {

    # Arguments
    local archieve_
    
    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
        '-d|--directory',dir
    )
    
    # Parse arguments to a named array
    parse_options_s

    # Parse arguments
    local archieve_="${posargs[0]}"

    # Parse options
    local dir_="${options[dir]:-.}"

    # -------------------------------------------------

    # Assert that the ZIP archieve was given
    [[ $(get_archieve_format "$archieve_") == "zip" ]] || return 1

    # Make destination directory, if needed
    mkdir -p "$dir_" || return 1

    # Extract archieve
    if is_var_set options[verbose]; then
        extract_zip_archieve.py --directory="$dir_" --show-progress "$archieve_" && return 0 || return 1
    else
        unzip -d "$dir_" "$archieve_" &> /dev/null && return 0 || return 1
    fi

}