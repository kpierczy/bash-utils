#!/usr/bin/env bash
# ====================================================================================================================================
# @file     archieves.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 5:36:08 pm
# @modified Thursday, 4th November 2021 6:52:32 pm
# @project  BashUtils
# @brief
#    
#    Set of functions related to files' archieves
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Extracts the file with the progress barr
# @param ... (optional)
#    parameteres passed to tar
# @param archieve
#    name of the archieve to be extracted
#
# @note Don't pass -f option to the function, as file is read by the
#    `tar` command from the stdin
# @note When extracting a compressed archieve, pass option 
#    corresponding to the compression type. As file is read by `tar`
#    from stdin, the compression type cannot be deduced from the
#    filename
# -------------------------------------------------------------------
extract_with_progress_bar() {
    pv "${@: -1}" | tar "${@:1:$#-1}"
}
