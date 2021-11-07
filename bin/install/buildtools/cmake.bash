#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cmake.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 3:14:23 pm
# @modified Sunday, 7th November 2021 5:12:45 pm
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
LOG_CONTEXT="cmake"

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

    logc_info "Building CMake..."
    pushd $EXTRACTED_PATH

    # Bootstrap CMake
    if ! ./bootstrap --prefix=$CMAKE_INSTALL_DIR; then
        popd
        logc_error "Failed to configure CMake"
        return 1
    fi
    # Build CMake
    if ! make; then
        popd
        logc_error "Failed to build CMake"
        return 1
    fi

    logc_info "CMake built"

    # Install CMake
    mkdir -p $CMAKE_INSTALL_DIR
    if ! make install; then
        popd
        logc_error "Failed to install CMake"
        return 1
    fi

    popd
    logc_info "CMake installed"

    # Remove sources
    if [[ $BASH_UTILS_RM_DOWNLOADED -eq "1" ]]; then
        logc_info "Deleting downloaded sources..."
        rm -rf $ARCHIEVE_PATH
        rm -rf $EXTRACTED_PATH
        logc_info "Sources deleted"
    fi

}

cmake_install_bin() {

    # Install CMake
    logc_info "Installing CMake to $CMAKE_INSTALL_DIR"
    mkdir -p $(dirname $CMAKE_INSTALL_DIR)
    mv $EXTRACTED_PATH $CMAKE_INSTALL_DIR
    logc_info "Cmake installed"

}

main() {

    # Arguments
    local installation_type

    # Options
    local defs=(
        '--help',help,f
    )

    # Parsed options
    parse_arguments

    # Parse arguments
    installation_type=${1:-}

    # Verify arguments
    [[ $installation_type == "source" || $installation_type == "bin" ]] || {
        logc_error "Invalid installation type ($installation_type)"
        echo $usage
        return 1
    }

    enable_globbing
    
    # Download URL
    local URL
    is_var_set_non_empty CMAKE_URL       && URL=$CMAKE_URL     ||
    [[ $installation_type == "source" ]] && URL=$CMAKE_SRC_URL || 
    [[ $installation_type == "bin"    ]] && URL=$CMAKE_BIN_URL
    # CMake download directory
    local DOWNLOAD_DIR="/tmp"

    # Prepare names for downloaded archieve
    prepare_names_for_downloaded_archieve
    # Path to the extracted CMake files
    local EXTRACTED_PATH=$DOWNLOAD_DIR/$EXTRACTED_NAME

    # Dependencies of the script
    local -a dependencies=(
        gcc  # GCC build tool
        curl # curl download tool
        make # make build system
    )

    # Check if CMake version was given
    is_var_set_non_empty CMAKE_VERSION || {
        logc_error "No CMake version given. Please export CMAKE_VERSION before running the script "
        return 1
    }

    # Check if CMake is already installed
    [[ -f $CMAKE_INSTALL_DIR/bin/cmake ]] && return

    # Install dependencies
    sudo apt update && install_packages -yv --su dependencies

    # Download and extract CMake
    CURL_FLAGS='-C -' LOG_CONTEXT=$LOG_CONTEXT LOG_TARGET="CMake" download_and_extract -v \
        $URL $DOWNLOAD_DIR $DOWNLOAD_DIR || return 1

    # Install CMake
    [[ $installation_type == "source" ]] && cmake_install_source || 
    [[ $installation_type == "bin"    ]] && cmake_install_bin

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
