#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cli_v1_autocompletion.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 5:01:29 pm
# @modified Wednesday, 23rd February 2022 1:32:41 am
# @project  bash-utils
# @brief
#    
#    Installs autocompletion script for MBed CLI v1
#    
# @soource https://github.com/ARMmbed/mbed-cli
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs autocompletion script for Mbed CLI v1"

# Options' descriptions
declare -A opts_description=(
    [destination]="script's installation"
)

# ========================================================== Configuration ========================================================= #

# Logging context of the script
declare LOG_CONTEXT="mbed"

# URL to be downloaded
declare GIT_URL='https://github.com/ARMmbed/mbed-cli'
# Location of the script (relative to the repositorie's root)
declare SCRIPT_LOCATION=tools/bash_completion/mbed
# Download directory
declare DOWNLOAD_DIR='/tmp'

# ============================================================ Commands ============================================================ #

function install() {

    log_info "Downloading Mbed CLI autocompletion script..."

    # Download the homebrew
    if ! git clone $GIT_URL $DOWNLOAD_DIR; then
        [[ $? != 128 ]] || {
            log_error "Failed to download Mbed CLI autocompletion script"
            exit 1
        }
    fi

    log_info "Script downloaded"

    # Copy script from the repository to the destination
    cp $DOWNLOAD_DIR/$SCRIPT_LOCATION ${opts[destination]}
    # Remove downloaded repository
    rm -rf $DOWNLOAD_DIR/${GIT_URL##*/}

}

# ============================================================== Main ============================================================== #

function main() {

    # Options
    local -A destination_opt_def=( [format]="--destination" [name]="destination" [type]="p" [default]="./mbed_cli_autocomplete" )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi

    # Install CLI
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

