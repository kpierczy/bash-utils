#!/usr/bin/env bash
# ====================================================================================================================================
# @file     arm-embedded.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 1:51:48 pm
# @modified Sunday, 21st November 2021 4:20:56 pm
# @project  bash-utils
# @brief
#    
#    Installs the given version of the ARM-Embedded-Toolchain
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Helper URL
declare HELPER_SITE="https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads"

# Script's usage
get_heredoc usage <<END
    Description: Installs requested version of the ARM-Embedded-Toolchain binaries for the current 
        platform (x86_64 or aarch64 supported)
    Usage: arm-embedded.bash VERSION

    Arguments:

        VERSION target version of the toolchain 

    Options:
      
        --help     if no command given, displays this usage message
        -u, --url  custom URL to be used to download the toolchain (by default 
                   toolchain is downloaded from the ARM's website deduced
                   based on the toolchain's version)
        --prefix   installation prefix (default: .)
        --dirname  name that the toolchain's dirctory should be changed to after
                   being extracted (realative to --prefix)
        --cleanup  if set, the downloaded archieve will be removed after being downloaded

    Note: You can acquire VERSIOn of the toolchain to be downloaded by visiting $HELPER_SITE and inspecting part 
          of the name of the toolchain between 'gcc-arm-none-eabi-' and '-<ARCHITECTURE>.<ARCHIEVE_EXTENSION>'

END

# ========================================================== Configuration ========================================================= #

# Scheme used to deduce default URL of the toolchain to be downloaded
declare DEFAULT_URL_SCHEME='https://developer.arm.com/-/media/Files/downloads/gnu-rm/$VERSION/gcc-arm-none-eabi-$VERSION-$ARCH-linux.tar.bz2'

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="arm-toochain"

# ============================================================ Commands ============================================================ #

install_toolchain() {

    # Arguments
    local VERSION="${1:-}"

    # Get the target URL
    if is_var_set_non_empty options[url]; then
        local URL=${options[url]}
    elif is_var_set_non_empty VERSION; then

        # Get system's architecture
        case $(get_system_arch) in
            x86_64  ) local ARCH=$(get_system_arch);;
            aarch64 ) local ARCH=$(get_system_arch);;
            *       ) log_error "Architecture's not supported ($(get_system_arch))"
                      exit 1;;
        esac
        # Evaluate the target URL
        local URL=$(eval "echo $DEFAULT_URL_SCHEME")
        
    else
        log_error "Invalid usage"
        echo $USAGE
    fi

    local PREFIX="${options[prefix]:-.}"

    # Download and extract the toolchain
    download_and_extract $URL               \
        --arch-dir=/tmp                     \
        --extract-dir=$PREFIX               \
        --show-progress                     \
        --verbose                           \
        --log-target="ARM Embedded Toolchain"
    [[ $? == 0 ]] || exit 1

    # Rename toolchain's folder
    is_var_set_non_empty options[dirname] &&
        mv $PREFIX/gcc-arm-none-eabi-$VERSION $PREFIX/${options[dirname]}

    # If option given, remove archieve
    is_var_set_non_empty options[cleanup] &&
        rm /tmp/gcc-arm-none-eabi-${VERSION}*.tar.bz2

    exit $?
}

# ============================================================== Main ============================================================== #

main() {

    # Link USAGE message
    local -n USAGE=usage

    # Commands imlemented by the script
    local ARG_NUM=1
    local -a arguments=(
        version
    )

    # Options
    local -a opt_definitions=(
        '--help',help,f
        '-u|--url',url
        '--prefix',prefix
        '--dirname',dirname
        '--cleanup',cleanup,f
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1

    # Parse arguments
    parse_arguments

    # ----------------------------- Run installation script -----------------------------

    install_toolchain ${version:-}

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

