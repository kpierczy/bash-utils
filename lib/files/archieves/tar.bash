#!/usr/bin/env bash
# ====================================================================================================================================
# @file     tar.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 11th November 2021 11:45:54 pm
# @modified Monday, 21st February 2022 6:58:11 pm
# @project  bash-utils
# @brief
#    
#    Set of tools related to tar archieves
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Extracts content of the tarbal archieve file (may be 
#   compressed with bz2, gz or xa format)
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
function extract_tar_archieve() {

    # Arguments
    local archieve_

    # ----------------- Configuration -----------------
    
    # Commands used to extract archieves of specified formats
    local -A EXTRACTION_OPTION_=(
            [tar]=''
         [tar.gz]='z'
        [tar.bz2]='j'
         [tar.xz]='J'
    )

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

    # Enable (locally) word splitting to properly parse arguments
    localize_word_splitting
    enable_word_splitting

    # Get array of supported formats
    local -a supported_formats_=( "${!EXTRACTION_OPTION_[@]}" )

    local format_

    # Get format of the archieve
    format_=$(get_archieve_format "$archieve_") || return 1
    
    # Assert that the ZIP archieve was given
    is_array_element supported_formats_ "$format_" || return 1

    # Make destination directory, if needed
    mkdir -p "$dir_" || return 1

    # Extract archieve
    if is_var_set options[verbose]; then
        pv "$archieve_" | tar "${EXTRACTION_OPTION_[$format_]}"x --directory=${options[dir]:-.} > /dev/null || return 1
    else
        tar "${EXTRACTION_OPTION_[$format_]}"xf "$archieve_" --directory=${options[dir]:-.} > /dev/null || return 1
    fi

}