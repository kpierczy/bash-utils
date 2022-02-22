#!/usr/bin/env bash
# ====================================================================================================================================
# @file     miktex.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Friday, 5th November 2021 6:40:39 pm
# @modified Wednesday, 23rd February 2022 12:06:31 am
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

# Description of the script
declare cmd_description="Installs MiKTeX package via apt"

# Arguments' descriptions
declare -A pargs_description=(
    [cmd]="command to be executed"
)

# Options' descriptions
declare -A opts_description=(
    [user]="installs/upgrade MiKTeX for the user (by default, script operates on the system-wide installation of miktex)"
)

# Commands' description
get_heredoc commands_description <<END
Commands:

    install  installas MiKTeX
    update   updades current installation of the MiKTeX; if MiKTeX is not installed, installs it
    upgrade  upgrades current installation of the MiKTeX to the full version (installs all packages)
END

# ============================================================ Constants =========================================================== #

# Source of the MiKTeX package
declare MIKTEX_APT_SOURCE="deb http://miktex.org/download/ubuntu focal universe"
# Path to the apt source file for the MiKTeX package
declare MIKTEX_APT_SOURCE_FILE="/etc/apt/sources.list.d/miktex.list"
# MiKTeX GPG key server
declare MIKTEX_GPG_KEY_SERVER="hkp://keyserver.ubuntu.com:80"
# MiKTeX GPG key
declare MIKTEX_GPG_KEY="D6BC243565B2087BC3F897C9277A7293F59E4889"

# Logging context of the script
declare LOG_CONTEXT="miktex"

# ============================================================ Functions =========================================================== #

function install_miktex() {

    # Check if MiKTeX already installed
    which miktex-pdflatex> /dev/null && return

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
    log_info "Finalizing MiKTeX setup"
    
    # Prepare flags for MiKTeX setup
    local setup_mode=''
    local miktex_flags=''
    is_var_set opts[user] && 
        miktex_flags='--shared=yes' ||
        setup_mode='sudo'
    # Finish MiKTeX setup
    $setup_mode miktexsetup finish $miktex_flags || {
        log_error "Could not finish MiKTeX setup"
        return 1
    }

    log_info "MiKTeX setup finished"

    # Enable automatic package installation
    is_var_set opts[user] && 
        $(      initexmf         --set-config-value [MPM]AutoInstall=1 ) || 
        $( sudo initexmf --admin --set-config-value [MPM]AutoInstall=1 ) || 
    {
        log_error "Could not enable automatic package installation"
        return 1
    }
    
}

function update_miktex() {
    
    # Check if MiKTeX was already installed
    which miktex-pdflatex> /dev/null || {
        install_miktex
        return
    }

    # Otherwise, update MiKTeX
    sudo apt update && sudo apt upgrade miktex

}

function upgrade_miktex() {
    
    log_info "Upgrading MiKTeX ..."

    # Upgrade MiKTeX
    is_var_set opts[user] &&
        $(      mpm         --verbose --package-level=complete --upgrade ) ||
        $( sudo mpm --admin --verbose --package-level=complete --upgrade )
    
    log_info "MiKTeX upgraded.."

}

# ============================================================== Main ============================================================== #

function main() {

    # Arguments
    local -A cmd_parg_def=( [format]="COMMAND" [name]="cmd" [type]="s" [variants]="install | update | upgrade" )

    # Options
    local -A a_prefix_opt_def=( [format]="--U|--user" [name]="user" [type]="f" )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help                                          )
    PARSEARGS_OPTS+=( --verbose                                            )
    PARSEARGS_OPTS+=( --with-append-pargs-description=commands_description )

    # Parse arguments
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi
    
    # Perform corresponding routine
    case ${pargs[cmd]} in
        install ) install_miktex ;;
        update  ) update_miktex  ;;
        upgrade ) upgrade_miktex ;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
