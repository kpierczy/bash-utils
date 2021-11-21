#!/usr/bin/env bash
# ====================================================================================================================================
# @file     homebrew.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 4:02:56 pm
# @modified Sunday, 21st November 2021 8:47:19 pm
# @project  BashUtils
# @brief
#    
#    Installs homebrew packages manager
#    
# @soource https://github.com/Homebrew/brew
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Script's usage
get_heredoc usage <<END
    Description: Installs homebre packages' manager
    Usage: homebrew.bash

    Options:
      
        --help                   if no command given, displays this usage message
        --prefix=DIR             installation prefix
        --print-source-str=FILE  if set, the script will print commands that should be run to use the homebrew
                                 to the FILE

END

# ========================================================== Configuration ========================================================= #

# Repositorie's URL
declare GIT_URL='https://github.com/Homebrew/brew'

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="homebrew"

# ============================================================ Commands ============================================================ #

install() {

    local PREFIX=${options[prefix]:-.}

    # Dependencies
    local -a dependencies=(
        build-essential
        procps
        curl
        file
        git   
    )

    # Download dependencies
    install_pkg_list --su -y -v -U dependencies || {
        log_error "Failed to install dependencies"
        exit 1
    }

    log_info "Downloading homebrew..."

    # Download the homebrew
    if ! git clone $GIT_URL $PREFIX/homebrew; then
        [[ $? != 128 ]] || {
            log_error "Failed to download homebrew"
            exit 1
        }
    fi

    log_info "Updating homebrew..."

    # Update homebrew
    eval "$($PREFIX/homebrew/bin/brew shellenv)" &&
    brew update --force --quiet                  &&
    chmod -R go-w "$(brew --prefix)/share/zsh"   || {
        log_error "Failed to update homebrew"
        exit 1
    }

    # Add source commands to the ~/.bashrc, if requested
    is_var_set_non_empty options[print_source] && {

        print_lines                                          \
            "eval \"$($PREFIX/homebrew/bin/brew shellenv)\"" \
            "brew update --force --quiet"                    \
            "chmod -R go-w \"$(brew --prefix)/share/zsh\""   \
        >${options[print_source]}
        
    }

}

# ============================================================== Main ============================================================== #

main() {

    # Link USAGE message
    local -n USAGE=usage

    # Options
    local -a opt_definitions=(
        '--help',help,f
        '--prefix',prefix
        '--print-source-str',print_source
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
