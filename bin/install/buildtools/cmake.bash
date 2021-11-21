#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cmake.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 3:14:23 pm
# @modified Sunday, 21st November 2021 11:16:02 pm
# @project  BashUtils
# @brief
#    
#    Installation script for the CMake
#    
# @source
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs CMake build tool
    Usage: cmake.bash TYPE

    Arguments

           TYPE  installation type (either 'src' for installation from sources, or 'bin'
                 for binary package installation)
        VERSION  version of the CMake to be installed

    Options:

        --help     displays this usage message
        --prefix   Installation directory of the cmake (default /opt/cmake)
        --url      custom URL to be used for downloading (default: official CMake github)
        --cleanup  if set, the downloaded archieve will be removed after being downloaded

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="cmake"

# ========================================================== Configruation ========================================================= #

# Installation directory for the CMake
declare DEFAULT_PREFIX='/opt/cmake'
# Scheme of the URL of the CMake source code
declare SRC_URL_SCHEME='https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION.tar.gz'
# Scheme of the URL of the CMake binary variant
declare BIN_URL_SCHEME='https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION-linux-$ARCH.tar.gz'

# ============================================================== Main ============================================================== #

install_src() {

    # Evaluate the target URL
    local URL=$(eval "echo $SRC_URL_SCHEME")


    # Name of the directory extracted from the archieve
    local TARGET=${URL##*/}
          TARGET=${TARGET%.tar.gz}

    # Name fo the configruation script
    local CONFIG_TOOL='bootstrap'
    # Configruation flags
    local CONFIG_FLAGS="--prefix=${options[prefix]:-$DEFAULT_PREFIX}"

    # Download and isntall CMake
    download_build_and_install $URL     \
        --verbose                      \
        --arch-dir=/tmp                \
        --extract-dir=/tmp             \
        --show-progress                \
        --src-dir=$TARGET              \
        --build-dir=/tmp/$TARGET/build \
        --log-target="CMake"           \
        --force

    # If option given, remove archieve
    is_var_set_non_empty options[cleanup] &&
        rm /tmp/${TARGET}*.tar.gz
        
}

install_bin() {

    # Get system's architecture
    case $(get_system_arch) in
        x86_64          ) local ARCH='x86_64';;
        arm64 | aarch64 ) local ARCH='aarch64';;
        *               ) log_error "Architecture's not supported ($(get_system_arch))"
                          exit 1;;
    esac
    # Evaluate the target URL
    local URL=$(eval "echo $BIN_URL_SCHEME")

    local PREFIX="${options[prefix]:-$DEFAULT_PREFIX}"

    # Download and extract the toolchain
    download_and_extract $URL            \
        --arch-dir=/tmp                  \
        --extract-dir=$(dirname $PREFIX) \
        --show-progress                  \
        --verbose                        \
        --log-target="CMake"
    [[ $? == 0 ]] || exit 1

    # Name of the directory extracted from the archieve
    local TARGET=${URL##*/}
          TARGET=${TARGET%.tar.gz}

    # Rename toolchain's folder
    mv $(dirname $PREFIX)/$TARGET $PREFIX

    # If option given, remove archieve
    is_var_set_non_empty options[cleanup] &&
        rm /tmp/${TARGET}*.tar.gz

}

# ============================================================== Main ============================================================== #

main() {

    local -n USAGE=usage

    # Arguments
    local -a arguments=(
        installation_type
        VERSION
    )

    # Variants of the first arguments
    local -a ARG1_VARIANTS=(
        src
        bin
    )

    # Options
    local opt_definitions=(
        '--help',help,f
        '--prefix',prefix
        '--url',url
        '--cleanup',cleanup,f
    )

    # Parsed options
    parse_arguments

    # Dependencies of the script
    local -a dependencies=( build-essential )

    # Install dependencies
    install_pkg_list --allow-local-app --su -y -v -U dependencies || {
        log_error "Failed to download CMake's dependencies"
        exit 1
    }

    # Run installation script
    case $installation_type in
        src ) install_src;;
        bin ) install_bin;;
    esac

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
