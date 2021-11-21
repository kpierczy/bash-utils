#!/usr/bin/env bash
# ====================================================================================================================================
# @file     serialplot.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 5:09:51 pm
# @modified Sunday, 21st November 2021 5:16:24 pm
# @project  BashUtils
# @brief
#    
#    Installs seriaplot app
#    
# @source https://serialplot.ozderya.net/downloads
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Script's usage
get_heredoc usage <<END
    Description: Installs autocompletion script for Mbed CLI v1
    Usage: homebrew.bash

    Options:
      
        --help              if no command given, displays this usage message
        --destination=FILE  script's installation (default ./serialplot)

END

# ========================================================== Configuration ========================================================= #

# URL to be downloaded
declare URL='https://serialplot.ozderya.net/downloads/serialplot-0.12.0-x86_64.AppImage'

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="serialplot"

# ============================================================ Commands ============================================================ #

install() {

    # Destination for the seriaplot 
    local DESTINATION=${options[destination]:-./seriaplot}

    log_info "Downloading seriaplot..."

    # Download the homebrew
    wget $URL                          \
        --no-verbose                   \
        --output-document=$DESTINATION \
        --show-progress || 
    {
        log_error "Failed to download seriaplot"
        exit 1
    }

    log_info "Script downloaded"

    # Add execution right to the seriaplot
    chmod +x $DESTINATION

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

