#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cmake.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 3:14:23 pm
# @modified Friday, 5th November 2021 5:05:18 pm
# @project  BashUtils
# @brief
#    
#    Installation script for the CMake
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================


# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs/uninstalls CMake build tool
    Usage: cmake.bash TYPE

    Arguments

        TYPE  installation type (either 'source' for installation from sources, or 'bin'
              for binary package installation)

    Environment:

        CMAKE_INSTALL_DIR  Installation directory of the cmake (default /opt/cmake)
            CMAKE_VERSION  Version of the CMake to be downloaded
                CMAKE_URL  (optional) CMake download URL. If not given, CMake is
                           downloaded from the official repository. If given, must provide
                           URL to the archive corresponding to the choosen installation type
                           (source archieve for 'source' or binary archieve for 'bin')

    Options:
      
        --help  displays this usage message

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
CONTEXT="cmake"

# ========================================================== Configruation ========================================================= #

# Installation directory for the CMake

var_set_default CMAKE_INSTALL_DIR '/opt/cmake'
# Version of the CMake to be installed
var_set_default CMAKE_VERSION ''
# URL of the CMake source code
var_set_default CMAKE_SRC_URL "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz"
# URL of the CMake binary package
var_set_default CMAKE_BIN_URL "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz"

# ============================================================== Main ============================================================== #

cmake_install_source() {

    log_info "$CONTEXT" "Building CMake..."
    pushd $CMAKE_EXTRACTED_PATH

    # Bootstrap CMake
    if ! ./bootstrap --prefix=$CMAKE_INSTALL_DIR; then
        popd
        log_error "$CONTEXT" "Failed to configure CMake"
        return 1
    fi
    # Build CMake
    if ! make; then
        popd
        log_error "$CONTEXT" "Failed to build CMake"
        return 1
    fi

    log_info "$CONTEXT" "CMake built"

    # Install CMake
    mkdir -p $CMAKE_INSTALL_DIR
    if ! make install; then
        popd
        log_error "$CONTEXT" "Failed to install CMake"
        return 1
    fi

    popd
    log_info "$CONTEXT" "CMake installed"

    # Remove sources
    if [[ $BASH_UTILS_RM_DOWNLOADED -eq "1" ]]; then
        log_info "$CONTEXT" "Deleting downloaded sources..."
        rm -rf $CMAKE_ARCHIEVE_PATH
        rm -rf $CMAKE_SOURCE_PATH
        log_info "$CONTEXT" "Sources deleted"
    fi

}

cmake_install_bin() {

    # Install CMake
    log_info "$CONTEXT" "Installing CMake to $CMAKE_INSTALL_DIR"
    mv $CMAKE_EXTRACTED_PATH $CMAKE_INSTALL_DIR
    log_info "$CONTEXT" "Cmake installed"

}

main() {

    # Arguments
    local installation_type

    # Options
    local defs=(
        '--help',help,f
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

    # Parse arguments
    installation_type=${1:-}

    # Verify arguments
    [[ $installation_type == "source" || $installation_type == "bin" ]] || {
        log_error "$CONTEXT" "Invalid installation type ($installation_type)"
        echo $usage
        return 1
    }

    enable_globbing
    
    # Download URL
    local CMAKE_URL
    [[ $installation_type == "source" ]] && var_set_default CMAKE_URL "$CMAKE_SRC_URL" || 
    [[ $installation_type == "bin"    ]] && var_set_default CMAKE_URL "$CMAKE_BIN_URL"
    # CMake download directory
    local CMAKE_DOWNLOAD_DIR="/tmp"
    # CMake download directory
    local CMAKE_ARCHIEVE_PATH="$CMAKE_DOWNLOAD_DIR/${CMAKE_URL##*/}"
    # Path to the extracted CMake files
    local CMAKE_EXTRACTED_PATH="${CMAKE_ARCHIEVE_PATH%.tar.gz}"

    # Dependencies of the script
    local -a dependencies=(
        gcc  # GCC build tool
        curl # curl download tool
        make # make build system
    )

    # Check if CMake version was given
    is_var_set CMAKE_VERSION || {
        log_error "$CONTEXT" "No CMake version given. Please export CMAKE_VERSION before running the script "
        return 1
    }

    # Check if CMake is already installed
    [[ -f $CMAKE_INSTALL_DIR/bin/cmake ]] && return

    # Install dependencies
    sudo apt update && install_packages -yv --su dependencies

    # Download and extract CMake
    LOG_CONTEXT=$CONTEXT LOG_TARGET="CMake" download_and_extract -v \
        $CMAKE_URL $CMAKE_DOWNLOAD_DIR $CMAKE_DOWNLOAD_DIR || return 1

    # Install CMake
    [[ $installation_type == "source" ]] && cmake_install_source || 
    [[ $installation_type == "bin"    ]] && cmake_install_bin

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
