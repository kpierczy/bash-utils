#!/usr/bin/env bash
# ====================================================================================================================================
# @file     homebrew.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 4:02:56 pm
# @modified Wednesday, 23rd February 2022 1:32:41 am
# @project  bash-utils
# @brief
#    
#    Installs homebrew packages manager
#    
# @soource https://github.com/Homebrew/brew
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs homebre packages' manager"

# Options' descriptions
declare -A opts_description=(
    [prefix]="installation prefix"
    [print_str]="if set, the script will print commands that should be run to use the homebrew to the FILE"
)

# Script's usage
get_heredoc usage <<END
    Description: Installs homebre packages' manager
    Usage: homebrew.bash

    Options:
      
        --help                   if no command given, displays this usage message
        --prefix=DIR             installation prefix
        --print-source-str=FILE  if set, the script will print commands that should be run to use the homebrew to the FILE

END

# ========================================================== Configuration ========================================================= #

# Repositorie's URL
declare GIT_URL='https://github.com/Homebrew/brew'

# ============================================================ Constants =========================================================== #

# Logging context of the script
declare LOG_CONTEXT="homebrew"

# ============================================================ Commands ============================================================ #

function install() {

    # ---------------------------- Installing dependencies ------------------------------

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
    
    # --------------------------- Installing python package -----------------------------

    # Transform prefix to absolute path
    opts[prefix]=$(realpath ${opts[prefix]})
    
    log_info "Downloading homebrew..."

    # Download the homebrew
    if ! git clone $GIT_URL ${opts[prefix]}/homebrew; then
        [[ $? != 128 ]] || {
            log_error "Failed to download homebrew"
            exit 1
        }
    fi

    log_info "Updating homebrew..."

    # Update homebrew
    eval "$(${opts[prefix]}/homebrew/bin/brew shellenv)" &&
    brew update --force --quiet                          &&
    chmod -R go-w "$(brew --prefix)/share/zsh"   || {
        log_error "Failed to update homebrew"
        exit 1
    }

    # Add source commands to the ~/.bashrc, if requested
    is_var_set_non_empty options[print_str] && {

        print_lines                                                  \
            "eval \"$(${opts[prefix]}/homebrew/bin/brew shellenv)\"" \
            "brew update --force --quiet"                            \
            "chmod -R go-w \"$(brew --prefix)/share/zsh\""           \
        >${options[print_str]}
        
    }

}

# ============================================================== Main ============================================================== #

function main() {

    # Options
    local -A  a_prefix_opt_def=( [format]="--prefix"           [name]="prefix"    [type]="p" [default]="." )
    local -A b_dirname_opt_def=( [format]="--print-source-str" [name]="print_str" [type]="p"               )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )

    # Parse arguments
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi

    # Run installation script
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
