#!/usr/bin/env bash
# ====================================================================================================================================
# @file     serialplot.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 5:09:51 pm
# @modified Wednesday, 23rd February 2022 1:32:41 am
# @project  bash-utils
# @brief
#    
#    Installs seriaplot app
#    
# @source https://serialplot.ozderya.net/downloads
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Script's description
declare cmd_description="Installs serialplot utility"

# Option's descriptions
declare -A opts_description=(
    [path]="installation path"
)

# ========================================================== Configuration ========================================================= #

# URL to be downloaded
declare URL='https://serialplot.ozderya.net/downloads/serialplot-0.12.0-x86_64.AppImage'

# ============================================================ Constants =========================================================== #

# Logging context of the script
declare LOG_CONTEXT="serialplot"

# ============================================================ Commands ============================================================ #

function install() {

    log_info "Downloading seriaplot..."

    # Download the homebrew
    wget $URL                                          \
        --quiet                                        \
        --output-document=$(to_abs_path ${opts[path]}) \
        --show-progress || 
    {
        log_error "Failed to download seriaplot"
        exit 1
    }

    log_info "Script downloaded"

    # Add execution right to the seriaplot
    chmod +x ${opts[path]}

}

# ============================================================== Main ============================================================== #

function main() {

    # Options
    local -A path_opt_def=( [format]="--path" [name]="path" [type]="p" [default]="./serialplot" )

    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parse arguments
    parse_arguments

    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi
    
    # Install utility
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

