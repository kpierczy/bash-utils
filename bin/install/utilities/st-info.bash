#!/usr/bin/env bash
# ====================================================================================================================================
# @file     st-info.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 6:16:17 pm
# @modified Wednesday, 23rd February 2022 1:32:41 am
# @project  bash-utils
# @brief
#    
#    Installs ST-Info utility from source
#    
# @source https://github.com/stlink-org/stlink
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs ST-Info utility for STM microcontrollers"

# Arguments' descriptions
declare -A pargs_description=(
    [version]="version of the CMake to be installed"
)

# Options' descriptions
declare -A opts_description=(
    [prefix]="installation directory"
    [cleanup]="if set, the downloaded archieve will be removed after being downloaded"
    [copy_config]="if given, configuration of the USB devices from the ST-Info source files will be copied into the system"
)

# ========================================================== Configruation ========================================================= #

# Logging context of the script
declare LOG_CONTEXT="st-info"

# Scheme of the URL of the source code
declare URL_SCHEME='https://github.com/stlink-org/stlink/archive/refs/tags/v$VERSION.tar.gz'

# ============================================================== Main ============================================================== #

function install_dependencies() {

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

}


function install() {

    # Evaluate the target URL
    local url=$(VERSION="${pargs[version]}" eval "echo $URL_SCHEME")

    # Name of the directory extracted from the archieve
    local target=stlink-${pargs[version]}
    
    # Disable configruation step
    local CONFIG_TOOL=''
    # Configuration command
    local BUILD_TOOL='make clean release'
    # Configruation flags
    local INSTALL_FLAGS="DESTDIR=$(realpath ${opts[prefix]})"

    # # Download and isntall st-info
    download_build_and_install $url \
        --verbose-tools             \
        --verbose                   \
        --arch-dir=/tmp             \
        --extract-dir=/tmp          \
        --show-progress             \
        --src-dir=$target           \
        --build-dir=/tmp/$target    \
        --log-target="ST-Info"      \
        --mark

    # If USB configureation was requested to be copied to the system, copy it
    is_var_set_non_empty opts[copy_config] &&
        sudo cp /tmp/$target/config/udev/rules.d/* /etc/udev/rules.d

    # If option given, remove archieve
    is_var_set_non_empty opts[cleanup] &&
        rm /tmp/v${VERSION}.tar.gz     &&
        rm -rf /tmp/$target
        
}

# ============================================================== Main ============================================================== #

function main() {

    # Arguments
    local -A version_parg_def=( [format]="VERSION" [name]="version" [type]="s" )

    # Options
    local -A      a_prefix_opt_def=( [format]="--prefix"      [name]="prefix"      [type]="s" [default]="/opt" )
    local -A     b_cleanup_opt_def=( [format]="--cleanup"     [name]="cleanup"     [type]="f"                  )
    local -A c_copy_config_opt_def=( [format]="--copy-config" [name]="copy_config" [type]="f"                  )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi

    # Install dependencies
    install_dependencies
    # Run installation routine
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
