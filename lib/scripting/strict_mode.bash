#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strict_mode.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 1:51:42 am
# @modified Thursday, 24th February 2022 6:39:14 pm
# @project  bash-utils
# @brief
#    
#    Set of functions related to the strict-mode-driven bash scripts development
#    
# @see https://www.binaryphile.com/bash/2018/08/09/approach-bash-like-a-developer-part-11-strict-mode.html
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Enables/disables strict mode in the calling script
#
# @param query 
#    state of the strict mode to be set; either 'on' or 'off'
# -------------------------------------------------------------------
function strict_mode() {

    local query="$1"

    # Enable/disable strict-mode depending on the query
    case "$query" in
        on )
            set -o errexit;
            set -o nounset;
            set -o pipefail;
            ;;
        off )
            set +o errexit
            set +o nounset
            set +o pipefail
            ;;
    esac
}

# -------------------------------------------------------------------
# @brief Enables/disables strict mode in the calling script 
#    setting the @f traceback function as ERR handler
#
# @param query 
#    state of the strict mode to be set; either 'on' or 'off'
# -------------------------------------------------------------------
function strict_mode_tracable() {

    local query="$1"

    # Enable/disable strict-mode depending on the query
    case "$query" in
        on  )
            set -o errexit
            set -o errtrace
            set -o nounset
            set -o pipefail
            trap traceback ERR
            ;;
        off )
            set +o errexit
            set +o errtrace
            set +o nounset
            set +o pipefail
            trap - ERR
            ;;
    esac
}