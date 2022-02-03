#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cli_v1_autocompletion.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 5:01:29 pm
# @modified Sunday, 21st November 2021 8:35:27 pm
# @project  bash-utils
# @brief
#    
#    Installs autocompletion script for MBed CLI v1
#    
# @soource https://github.com/ARMmbed/mbed-cli
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Script's usage
get_heredoc usage <<END
    Description: Installs autocompletion script for Mbed CLI v1
    Usage: cli_v1_autocompletion.bash

    Options:
      
        --help              if no command given, displays this usage message
        --destination=FILE  script's installation (default ./mbed_cli_autocomplete)

END

# ========================================================== Configuration ========================================================= #

# URL to be downloaded
declare GIT_URL='https://github.com/ARMmbed/mbed-cli'

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="mbed"

# ============================================================ Commands ============================================================ #

install() {

    log_info "Downloading Mbed CLI autocompletion script..."

    # Download the homebrew
    if ! git clone $GIT_URL /tmp; then
        [[ $? != 128 ]] || {
            log_error "Failed to download Mbed CLI autocompletion script"
            exit 1
        }
    fi

    log_info "Script downloaded"

    # Location of the script relative to the repositorie's root
    local SCRIPT_LOCATION=tools/bash_completion/mbed
    # Destination for the script
    local DESTINATION=${options[destination]:-./mbed_cli_autocomplete}

    # Copy script from the repository to the destination
    cp /tmp/$SCRIPT_LOCATION $DESTINATION
    # Remove downloaded repository
    rm -rf /tmp/${GIT_URL##*/}

}

# ============================================================== Main ============================================================== #

main() {

    # Link USAGE message
    local -n USAGE=usage

    # Options
    local -a opt_definitions=(
        '--help',help,f
        '--destination',destination
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1

    # Parse arguments
    parse_arguments

    # ----------------------------- Run installation script -----------------------------

    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

