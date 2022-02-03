#!/usr/bin/env bash
# ====================================================================================================================================
# @file     openocd.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 4:36:43 pm
# @modified Sunday, 21st November 2021 8:36:26 pm
# @project  bash-utils
# @brief
#    
#    Installs OpenOCD progremmer/debugger software from the binary package
#    
# @source https://github.com/xpack-dev-tools/openocd-xpack/releases
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Script's usage
get_heredoc usage <<END
    Description: Installs OpenOCD progremmer/debugger software from the binrary package
    Usage: openocd.bash VERSION

    Arguments

        VERSION  version of hte OpenOCD to be downloaded (@see Source)

    Options:
      
        --help        if no command given, displays this usage message
        --prefix=DIR  installation prefix
        --dirname     name that the toolchain's dirctory should be changed to after
                      being extracted (realative to --prefix)
        --cleanup     if set, the downloaded archieve will be removed after being downloaded
        
    Source:
    
        https://github.com/xpack-dev-tools/openocd-xpack/releases

END

# ========================================================== Configuration ========================================================= #

# Scheme used to deduce default URL of the toolchain to be downloaded
declare URL_SCHEME='https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v$VERSION/xpack-openocd-$VERSION-linux-$ARCH.tar.gz'
# Schame of the name of the directory extracted from the archieve
declare TARGET_SCHEME='xpack-openocd-$VERSION'

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="openocd"

# ============================================================ Commands ============================================================ #

install() {

    # Get system's architecture
    case $(get_system_arch) in
        x86_64          ) local ARCH='x64';;
        armv7l          ) local ARCH='arm';;
        arm64 | aarch64 ) local ARCH='arm64';;
        *               ) log_error "Architecture's not supported ($(get_system_arch))"
                            exit 1;;
    esac
    # Evaluate the target URL
    local URL=$(eval "echo $URL_SCHEME")

    local PREFIX="${options[prefix]:-.}"

    # Download and extract the toolchain
    download_and_extract $URL  \
        --arch-dir=/tmp        \
        --extract-dir=$PREFIX  \
        --show-progress        \
        --verbose              \
        --log-target="OpenOCD"
    [[ $? == 0 ]] || exit 1

    local TARGET=$(eval "echo $TARGET_SCHEME")

    # Rename toolchain's folder
    is_var_set_non_empty options[dirname] &&
        mv $PREFIX/$TARGET $PREFIX/${options[dirname]}

    # If option given, remove archieve
    is_var_set_non_empty options[cleanup] &&
        rm /tmp/${TARGET}*.tar.gz

    exit $?
}

# ============================================================== Main ============================================================== #

main() {

    # Link USAGE message
    local -n USAGE=usage

    # Commands imlemented by the script
    local ARG_NUM=1
    local -a arguments=(
        VERSION
    )

    # Options
    local -a opt_definitions=(
        '--help',help,f
        '--prefix',prefix
        '--dirname',dirname
        '--cleanup',cleanup,f
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1

    # Parse arguments
    parse_arguments

    # Run installation script
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

