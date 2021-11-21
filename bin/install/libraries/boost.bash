#!/usr/bin/env bash
# ====================================================================================================================================
# @file     boost.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 1:13:17 pm
# @modified Sunday, 21st November 2021 10:18:09 pm
# @project  BashUtils
# @brief
#    
#    Script installs Boost library
#    
# @fixme
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs Boost library
    Usage: boost.bash TYPE [VERSION] [TARGET]

    Arguments:

          TYPE  type of the installation to be performed

                  pkg  installas Boost from apt package
                  src  installas Boost from source

        VERSION version of the boost to be installed in the 'src' variant

        TARGET  target to be installed in source variant
          
                 headers  installs only header files
                   stage  installs only comiples library files
                    full  installs full version of the boost

    Options:
      

                         --help  displays this usage message
                   --prefix=DIR  installation prefix when the 'src' variant is installed (default: .)
        --with-config-flags=STR  string containing configruation flags to be passed to the 
                                 boost's bootstrap step
       --with-compile-flags=STR  string containing configruation flags to be passed to the 
                                 boost's compilation step
END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="boost"

# ============================================================ Functions =========================================================== #

install_pkg() {

    # Boost package to be installed
    local BOOST_PKG="libboost-all-dev"

    # Check if package already isntalled
    ! is_pkg_installed $BOOST_PKG || return

    # Install package
    log_info "Installing boost package ..."
    sudo apt update && sudo apt install -y $BOOST_PKG || {
        log_error "Failed o install $BOOST_PKG" package
        return 1
    }

    log_info "Boost package installed"
    
}

install_source() {
    
    # Scheme of the URL of the boost to download sources 
    local URL_SCHEME='https://sourceforge.net/projects/boost/files/boost/$version/boost_${version//./_}.tar.bz2/download'
    # Boost download directory
    local DOWNLOAD_DIR="/tmp"
    # Supported targets
    local -a TARGETS=(
        headers
        stage
        full
    )
    
    # Verify target argument
    is_var_set_non_empty target && is_array_element TARGETS $target || {
        log_error "Invalid target given ($target)"
        echo $usage
        return 1
    }

    # Verify if boost version given
    is_var_set_non_empty version || {
        log_error "No boost version given"
        return 1
    }

    # Evaluate the target URL
    local URL=$(eval "echo $URL_SCHEME")

    # Name of the directory extracted from the archieve
    local TARGET=${URL##*/}
          TARGET=${TARGET%.tar.bz2*}

    # Get installation prefix
    local PREFIX=${options[prefix]:-.}

    # Name of the configruation script
    local CONFIG_TOOL='bootstrap'
    # Prepare configuration flags
    local CONFIG_FLAGS=''
    CONFIG_FLAGS+="--with-python=python3 "
    CONFIG_FLAGS+="--prefix=$PREFIX "
    CONFIG_FLAGS+="${options[config_flags]:-.} "
    # Name of the compilation script
    local BUILD_TOOL='./b2'
    # Prepare compilation target and 
    case $target in
        headers ) local target="headers"; local BUILD_FLAGS="--prefix=$PREFIX";;
        stage   ) local target="stage";   local BUILD_FLAGS="--stagedir=$PREFIX/lib";;
        full    ) local target="install"; local BUILD_FLAGS="--prefix=$PREFIX";;
    esac
    BUILD_FLAGS+=" ${options[compile_flags]:-}"

    # Download and isntall CMake
    WGET_FLAGS='--no-clobber'          \
    download_build_and_install $URL    \
        --verbose                      \
        --arch-path=/tmp/$TARGET       \
        --extract-dir=/tmp             \
        --show-progress                \
        --src-dir=$TARGET              \
        --target=$target               \
        --build-dir=/tmp/$TARGET/build \
        --log-target="Boost"           \
        --up-to=build                  \
        --force

    # If option given, remove archieve
    is_var_set_non_empty options[cleanup] &&
        rm /tmp/${TARGET}*.tar.bz2

}

# ============================================================== Main ============================================================== #

main() {
    
    # Link USAGE message
    local -n USAGE=usage

    # Requirewd number of arguments
    local ARG_NUM_MIN=1
    local -a arguments=(
        itype
        version
        target
    )
    # Valid variants of the `itype` argument
    local ARG1_VARIANTS=(
        pkg
        src
    )

    # Options
    local opt_definitions=(
        '--help',help,f
        '--prefix',prefix
        '--with-config-flags',config_flags
        '--with-compile-flags',compile_flags
        '--cleanup',cleanup,f
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1
    
    # Parsed options
    parse_arguments
    
    # Perform corresponding routine
    case $itype in
        pkg ) install_pkg;;
        src ) install_source;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
