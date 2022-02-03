#!/usr/bin/env bash
# ====================================================================================================================================
# @file     st-info.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 6:16:17 pm
# @modified Monday, 22nd November 2021 9:18:58 am
# @project  bash-utils
# @brief
#    
#    Installs ST-Info utility from source
#    
# @source https://github.com/stlink-org/stlink
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs ST-Info utility for STM microcontrollers
    Usage: cmake.bash VERSION

    Arguments

        VERSION  version of the CMake to be installed

    Options:

            --help     displays this usage message
            --prefix   Installation directory of the cmake (default /opt/cmake)
            --url      custom URL to be used for downloading (default: official github)
            --cleanup  if set, the downloaded archieve will be removed after being downloaded
        --copy-config  if given, configuration of the USB devices from the ST-Info source files
                       will be copied into the system
END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="st-info"

# ========================================================== Configruation ========================================================= #

# Scheme of the URL of the source code
declare URL_SCHEME='https://github.com/stlink-org/stlink/archive/refs/tags/v$VERSION.tar.gz'

# ============================================================== Main ============================================================== #

install() {

    # Evaluate the target URL
    local URL=$(eval "echo $URL_SCHEME")
    
    # Name of the directory extracted from the archieve
    local TARGET=stlink-$VERSION
    
    # Disable configruation step
    local CONFIG_TOOL=''
    # Configuration command
    local BUILD_TOOL='make clean release'
    # Configruation flags
    local INSTALL_FLAGS="DESTDIR=${options[prefix]:-$DEFAULT_PREFIX}"

    # Download and isntall CMake
    download_build_and_install $URL \
        --verbose-tools             \
        --verbose                   \
        --arch-dir=/tmp             \
        --extract-dir=/tmp          \
        --show-progress             \
        --src-dir=$TARGET           \
        --build-dir=/tmp/$TARGET    \
        --log-target="ST-Info"      \
        --force

    # If USB configureation was requested to be copied to the system, copy it
    is_var_set_non_empty options[copy_config] &&
        sudo cp /tmp/$TARGET/config/udev/rules.d/* /etc/udev/rules.d

    # If option given, remove archieve
    is_var_set_non_empty options[cleanup] &&
        rm /tmp/v${VERSION}.tar.gz        &&
        rm -rf /tmp/$TARGET
        
}

# ============================================================== Main ============================================================== #

main() {

    local -n USAGE=usage

    # Arguments
    local ARG_NUM=1
    local -a arguments=(
        VERSION
    )

    # Options
    local -a opt_definitions=(
        '--help',help,f
        '--prefix',prefix
        '--url',url
        '--cleanup',cleanup,f
        '--copy-config',copy_config
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1
    
    # Parsed options
    parse_arguments

    # Dependencies of the script
    local -a dependencies=(
        gcc
        build-essential
        git
        cmake
        rpm
        libusb-1.0-0-dev
        libgtk-3-dev
        pandoc
    )
    
    # Install dependencies
    install_pkg_list --allow-local-app --su -y -v dependencies || {
        log_error "Failed to download ST-Info's dependencies"
        exit 1
    }

    # Run installation routine
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
