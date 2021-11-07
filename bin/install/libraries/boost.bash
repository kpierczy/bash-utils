#!/usr/bin/env bash
# ====================================================================================================================================
# @file     boost.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 1:13:17 pm
# @modified Sunday, 7th November 2021 5:12:45 pm
# @project  BashUtils
# @brief
#    
#    Script installs Boost library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs Boost library
    Usage: boost.bash TYPE [TARGET]

    Arguments:

          TYPE  type of the installation to be performed

                  pkg  installas Boost from apt package
                  src  installas Boost from source

        TARGET  target to be installed in source variant
          
                 headers  installs only header files
                   stage  installs only comiples library files
                    full  installs full version of the boost

    Options:
      
        --help  displays this usage message

    Environment:

            BOOST_VERSION  Version of the Boost to be installed (src variant)
             BOOST_PREFIX  Installation prefix of the Boost (src variant)
    BOOST_BOOTSTRAP_FLAGS  Set of additional flags to be passed to boost bootstrap
      BOOST_COMPILE_FLAGS  Set of additional flags to be passed to boost compilation

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="boost"

# ========================================================== Configruation ========================================================= #

# Version of the boost to be installed (src variant)
var_set_default BOOST_VERSION ''
# Installation prefix of the boost library (src variant)
var_set_default BOOST_PREFIX '.'
# Set of additional flags to be passed to boost bootstrap
var_set_default BOOST_BOOTSTRAP_FLAGS ''
# Set of additional flags to be passed to boost compilation
var_set_default BOOST_COMPILE_FLAGS ''

# ============================================================ Functions =========================================================== #

install_boost_pkg() {

    # Boost package to be installed
    local BOOST_PKG="libboost-all-dev"

    # Check if package already isntalled
    ! is_pkg_installed $BOOST_PKG || return

    # Install package
    logc_info "Installing boost package ..."
    sudo apt update && sudo apt install $BOOST_PKG || {
        logc_error "Failed o install $BOOST_PKG" package
        return 1
    }

    logc_info "Boost package installed"
    
}

install_boost_source() {
    
    # URL of the boost to download sources from (src variant)
    local URL="https://sourceforge.net/projects/boost/files/boost/$BOOST_VERSION/boost_${BOOST_VERSION//./_}.tar.bz2/download"
    # Boost download directory
    local DOWNLOAD_DIR="/tmp"
    # Supported targets
    local TARGETS=(
        headers
        stage
        full
    )

    # Verify target argument
    is_var_set_non_empty target && is_one_of $target TARGETS ||
    {
        logc_error "Invalid target given ($target)"
        echo $usage
        return 1
    }

    # Verify if boost version given
    is_var_set_non_empty BOOST_VERSION || {
        logc_error "No boost version given"
        return 1
    }

    # Prepare download names
    URL=${URL%/download}
    prepare_names_for_downloaded_archieve
    URL="$URL/download"
    # Path to the extracted Boost files
    local EXTRACTED_PATH=$DOWNLOAD_DIR/$EXTRACTED_NAME

    # Download and extract Boost
    ARCH_NAME="boost_${BOOST_VERSION//./_}.tar.bz2" LOG_CONTEXT=$LOG_CONTEXT LOG_TARGET="Boost" \
    download_and_extract -v                                                                     \
        $URL/download $DOWNLOAD_DIR $DOWNLOAD_DIR || return 1

    pushd $EXTRACTED_PATH

    logc_info "Initializing Boost's bootstrap routine ..."

    # Prepare bootstrap flags
    local bootflags=''
    bootflags+=--with-python=python3
    bootflags+=--prefix=PREFIX=$BOOST_PREFIX

    # Bootstrap boost
    ./bootstrap.sh $bootflags $BOOST_BOOTSTRAP_FLAGS ||
    {
        logc_error "Failed to bootstrap Boost"
        popd
        return 1
    }

    logc_info "Boost sucesfully bootstrapped"
    logc_info "Bulding Boost ..."

    # Select build type
    local build_type=''
    local build_flags=''
    case $target in
        headers ) build_type="headers"; build_flags="--prefix=$BOOST_PREFIX";;
        stage   ) build_type="stage";   build_flags="--stagedir=$BOOST_PREFIX/lib";;
        full    ) build_type="install"; build_flags="--prefix=$BOOST_PREFIX";;
    esac

    # Preapre target directory
    mkdir -p $BOOST_PREFIX

    # Build boost
    ./b2 $build_type $build_flags $BOOST_COMPILE_FLAGS ||
    {
        logc_error "Failed to build Boost"
        popd
        return 1
    }

    logc_info "Sucesfully buit Boost"

}

# ============================================================== Main ============================================================== #

main() {
    
    # Arguments
    local itype

    # Requirewd number of arguments
    local ARG_NUM=1
    
    # Commands
    local ITYPES=(
        pkg
        src
    )

    # Options
    local defs=(
        '--help',help,f
    )

    # Parsed options
    parse_arguments

    # Parse argument
    itype=${1:-}
    target=${2:-}

    # Validate argument
    is_one_of $itype ITYPES || {
        logc_error "Invalid usage"
        echo $usage
        return 1
    }
    
    # Perform corresponding routine
    case $itype in
        pkg) install_boost_pkg;;
        src) install_boost_source;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
