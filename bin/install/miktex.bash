#!/usr/bin/env bash
# ====================================================================================================================================
# @file     miktex.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Friday, 5th November 2021 6:40:39 pm
# @modified Friday, 5th November 2021 7:51:26 pm
# @project  BashUtils
# @brief
#    
#    Script installs MiKTeX on the Ubuntu-based systems
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs MiKTeX
    Usage: miktex.bash TYPE

    Options:
      
            -U  installs MiKTeX for the user
        --help  displays this usage message

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="miktex"

# ========================================================== Configruation ========================================================= #


# ============================================================== Main ============================================================== #

main() {

    # Options
    local defs=(
        '--help',help,f
        '-U',user,f
    )

    # Parsed options
    declare -A options

    # Parse options
    enable_word_splitting
    parseopts "$*" defs options posargs
    disable_word_splitting

    # Display usage, if requested
    is_var_set options[help] && {
        echo $usage
        return 0
    }

    # Set positional arguments
    set -- ${posargs[@]}

    # Source of the MiKTeX package
    local MIKTEX_APT_SOURCE="deb http://miktex.org/download/ubuntu focal universe"
    # Path to the apt source file for the MiKTeX package
    local MIKTEX_APT_SOURCE_FILE="/etc/apt/sources.list.d/miktex.list"
    # MiKTeX GPG key server
    local MIKTEX_GPG_KEY_SERVER="hkp://keyserver.ubuntu.com:80"
    # MiKTeX GPG key
    local MIKTEX_GPG_KEY="D6BC243565B2087BC3F897C9277A7293F59E4889"

    # Register GPG key
    sudo apt-key adv --keyserver $MIKTEX_GPG_KEY_SERVER --recv-keys $MIKTEX_GPG_KEY

    # Add MiKTeX repository to apt
    [[ -f $MIKTEX_APT_SOURCE_FILE ]] ||
        echo $MIKTEX_APT_SOURCE | sudo tee $MIKTEX_APT_SOURCE_FILE

    logc_info "Installing MiKTeX ..."

    # Install MiKTeX
    sudo apt update && sudo apt install -y miktex || {
        logc_error "Could not install MiKTeX"
        return 1
    }

    logc_info "MiKTeX installed"
    
    # Finish MiKTeX setup
    logc_info "Finalizing MiKTeX setup"
    local setup_mode=''
    local miktex_flags=''
    is_var_set options[user] && setup_mode='sudo' && miktex_flags='--shared=yes'
    $setup_mode miktexsetup finish || {
        logc_error "Could not finish MiKTeX setup"
        return 1
    }

    logc_info "MiKTeX setup finished"

    # Enable automatic package installation
    is_var_set options[user] && 
        initexmf --set-config-value [MPM]AutoInstall=1 || 
        sudo initexmf --admin --set-config-value [MPM]AutoInstall=1 || 
    {
        logc_error "Could not enable automatic package installation"
        return 1
    }
        
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
