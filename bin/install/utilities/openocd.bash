#!/usr/bin/env bash
# ====================================================================================================================================
# @file     openocd.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 4:36:43 pm
# @modified Wednesday, 23rd February 2022 1:32:41 am
# @project  bash-utils
# @brief
#    
#    Installs OpenOCD progremmer/debugger software from the binary package
#    
# @source https://github.com/xpack-dev-tools/openocd-xpack/releases
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs OpenOCD programmer/debugger software from the binary package"

# Arguments' descriptions
declare -A pargs_description=(
    [version]="version of hte OpenOCD to be downloaded (@see Source)"
)

# Options' descriptions
declare -A opts_description=(
    [prefix]="installation prefix"
    [dirname]="name that the package's directory should be renamed to after being extracted (realative to --prefix)"
    [cleanup]="if set, the downloaded archieve will be removed after being downloaded"
)

# Additional info
get_heredoc source_description <<END
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
declare LOG_CONTEXT="openocd"

# ============================================================ Commands ============================================================ #

function install() {

    # Get system's architecture
    case $(get_system_arch) in
        x86_64          ) local ARCH='x64';;
        armv7l          ) local ARCH='arm';;
        arm64 | aarch64 ) local ARCH='arm64';;
        *               ) log_error "Architecture's not supported ($(get_system_arch))"
                            exit 1;;
    esac

    # Convert prefix to absolute path
    opts[prefix]=$(realpath ${opts[prefix]})
    # Evaluate the target URL
    local url=$( VERSION=${pargs[version]} eval "echo $URL_SCHEME" )
    # Evaluate target name
    local target=$( VERSION=${pargs[version]} eval "echo $TARGET_SCHEME" )

    # Download and extract the toolchain
    download_and_extract $url         \
        --arch-dir=/tmp               \
        --extract-dir=${opts[prefix]} \
        --show-progress               \
        --verbose                     \
        --log-target="OpenOCD"

    # Rename toolchain's folder
    is_var_set_non_empty opts[dirname] &&
        mv ${opts[prefix]}/$target ${opts[prefix]}/${opts[dirname]}

    # If option given, remove archieve
    is_var_set_non_empty opts[cleanup] &&
        rm /tmp/${target}*.tar.gz
    
}

# ============================================================== Main ============================================================== #

function main() {

    # Arguments
    local -A version_parg_def=( [format]="VERSION" [name]="version" [type]="s" )

    # Options
    local -A  a_prefix_opt_def=( [format]="--prefix"  [name]="prefix"  [type]="p" [default]="." )
    local -A b_dirname_opt_def=( [format]="--dirname" [name]="dirname" [type]="p"               )
    local -A c_cleanup_opt_def=( [format]="--cleanup" [name]="cleanup" [type]="f"               )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help                                  )
    PARSEARGS_OPTS+=( --verbose                                    )
    PARSEARGS_OPTS+=( --with-append-description=source_description )

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

