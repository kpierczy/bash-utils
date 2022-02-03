#!/usr/bin/env bash
# ====================================================================================================================================
# @file     miktex.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Friday, 5th November 2021 6:40:39 pm
# @modified Sunday, 21st November 2021 11:45:36 pm
# @project  bash-utils
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
    Usage: miktex.bash CMD

    Arguments:

        CMD action to be performed by the script
              'install'  installas MiKTeX
               'update'  updades current installation of the MiKTeX; if 
                         MiKTeX is not installed, installs it
              'upgrade'  upgrades current installation of the MiKTeX to the 
                         full version (installs all packages)

    Options:
      
            -U  installs/upgrade MiKTeX for the user (by default, script
                operates on the system-wide installation of miktex)
        --help  displays this usage message

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="miktex"

# ============================================================ Functions =========================================================== #

install_miktex() {

    # Check if MiKTeX already installed
    which miktex-pdflatex> /dev/null && return

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

    log_info "Installing MiKTeX ..."

    # Install MiKTeX
    sudo apt update && sudo apt install -y miktex || {
        log_error "Could not install MiKTeX"
        return 1
    }

    log_info "MiKTeX installed"
    
    # Finish MiKTeX setup
    log_info "Finalizing MiKTeX setup"
    local setup_mode=''
    local miktex_flags=''
    is_var_set options[user] && setup_mode='sudo' && miktex_flags='--shared=yes'
    $setup_mode miktexsetup finish || {
        log_error "Could not finish MiKTeX setup"
        return 1
    }

    log_info "MiKTeX setup finished"

    # Enable automatic package installation
    is_var_set options[user] && 
             initexmf         --set-config-value [MPM]AutoInstall=1 || 
        sudo initexmf --admin --set-config-value [MPM]AutoInstall=1 || 
    {
        log_error "Could not enable automatic package installation"
        return 1
    }
    
}

update_miktex() {
    
    # Check if MiKTeX was already installed
    which miktex-pdflatex> /dev/null || {
        install_miktex
        return
    }

    # Otherwise, update MiKTeX
    sudo apt update && sudo apt upgrade miktex

}

upgrade_miktex() {
    
    # Upgrade MiKTeX
    log_info "Upgrading MiKTeX ..."
    is_var_set options[user] &&
             mpm         --verbose --package-level=complete --upgrade
        sudo mpm --admin --verbose --package-level=complete --upgrade ||
    log_info "MiKTeX upgraded.."

}

# ============================================================== Main ============================================================== #

main() {

    local -n USAGE=usage

    # Arguments
    local cmd

    # Arguments
    local -a arguments=(
        cmd
    )
    local -a ARG1_VARIANTS=(
        install
        update
        upgrade
    )

    # Options
    local opt_definitions=(
        '--help',help,f
        '-U',user,f
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1    

    # Parse arguments
    parse_arguments
    
    # Perform corresponding routine
    case $cmd in
        install ) install_miktex;;
        update  ) update_miktex;;
        upgrade ) upgrade_miktex;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
