#!/usr/bin/env bash
# ====================================================================================================================================
# @file     defaults.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 7th November 2021 3:08:11 pm
# @modified Thursday, 24th February 2022 6:19:46 am
# @project  bash-utils
# @brief
#    
#    Default environment variables for GCC toolchain builtool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source helper functions
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/helpers.bash
# Source prerequisites-builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/prerequisites.bash
# Source components-builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/binutils.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/gcc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libgcc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/gdb.bash
# Source build finalizer
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/finalize.bash

# ============================================================ Constants =========================================================== #

# List of targets built by the script
declare -a TARGETS=(
    binutils
    gcc
    libc
    libc_aux
    libgcc
    libcpp
    gdb
    zlib
    gmp
    mpfr
    mpc
    isl
    libelf
    expat
    cloog
)

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Returns default version of the given @p implementation of the libc
#
# @param implementation
#     implementation to be processed (one of: {glibc, newlib, ulibc})
# @outputs
#     default version of the given @p implementation
# ---------------------------------------------------------------------------------------
function get_default_libc_version() {

    # Arguments
    local implementation="$1"

    # Return default version
    case ${implementation} in
        'glibc'                 ) echo "$TOOLCHAIN_GLIBC_VERSION"  ;;
        'newlib' |'newlib-nano' ) echo "$TOOLCHAIN_NEWLIB_VERSION" ;;
        'ulibc'                 ) echo "$TOOLCHAIN_ULIBC_VERSION"  ;;
    esac

}

# ---------------------------------------------------------------------------------------
# @brief Returns default download URL scheme of the given @p implementation of the libc
#
# @param implementation
#     implementation to be processed (one of: {glibc, newlib, ulibc})
# @outputs
#     default download URL scheme of the given @p implementation
# ---------------------------------------------------------------------------------------
function get_default_libc_url() {

    # Arguments
    local libc_implementation="$1"

    # Return default version
    case ${libc_implementation} in
        'glibc'                 ) echo "$TOOLCHAIN_GLIBC_URL_SCHEME"  ;;
        'newlib' |'newlib-nano' ) echo "$TOOLCHAIN_NEWLIB_URL_SCHEME" ;;
        'ulibc'                 ) echo "$TOOLCHAIN_ULIBC_URL_SCHEME"  ;;
    esac

}


# ---------------------------------------------------------------------------------------
# @brief Updates `opts` hash array with the choosen libc
# ---------------------------------------------------------------------------------------
function select_libc() {

    # Set default version of the libc and downlaod URL
    is_var_set opts[libc_version] || opts[libc_version]=$(get_default_libc_version ${opts[with_libc]})
    is_var_set opts[libc_url]     || opts[libc_url]=$(get_default_libc_url ${opts[with_libc]})
    
}

# ---------------------------------------------------------------------------------------
# @brief Installs script's dependencies
# ---------------------------------------------------------------------------------------
function install_dependencies() {

    # Enable usage of 32-bit packages
    sudo dpkg --add-architecture i386

    # Dependencies
    local -a dependencies=(
        software-properties-common
        build-essential
        autoconf
        autogen
        bison
        dejagnu
        flex
        flip
        gawk
        git
        gperf
        gzip
        nsis
        openssh-client
        p7zip-full
        perl
        python3-dev
        libisl-dev
        scons
        tcl
        texinfo
        tofrodos
        wget
        zip
        texlive
        texlive-extra-utils
        libncurses5-dev
    )

    # Install dependencies
    install_pkg_list --su -y -v -U dependencies || {
        log_error "Could not install required dependencies"
        return 1
    }
    
}


# ---------------------------------------------------------------------------------------
# @brief Parses @var pargs[components] hash array to acquire list of components to be
#    built by the script
#
# @requires components
#    hash array containing names of components associated with either '1' or '0'
#    depending on whether the component needs to be built or not respectively
# @requires components_list
#    array containing names of components IN ORDER
# ---------------------------------------------------------------------------------------
function parse_components() {

    # Prepare list of components to be built
    components=(
        [prerequisites]='1'
        [binutils]='0'
        [gcc]='0'
        [libc]='0'
        [libgcc]='0'
        [libcpp]='0'
        [gdb]='0'
    )

    # Array of components to be built (in order)
    components_list=(
        prerequisites
        binutils
        gcc
        libc
        libgcc
        libcpp
        gdb
    )

    # If no components given enable all to be built
    if is_var_set pargs[components]; then
        components[binutils]='1'
        components[gcc]='1'
        components[libc]='1'
        components[libgcc]='1'
        components[libcpp]='1'
        components[gdb]='1'
    # Otherwise check what components should e build
    else

        # Iterate over components and check which should be built
        for comp in ${pargs[@]}; do
            case $comp in
                'all' )

                    components[binutils]='1'
                    components[gcc]='1'
                    components[libc]='1'
                    components[libgcc]='1'
                    components[libcpp]='1'
                    components[gdb]='1'
                    break
                    ;;

                'binutils' )

                    components[binutils]='1'
                    ;;

                'gcc' )

                    components[gcc]='1'
                    ;;

                'libc' )

                    components[libc]='1'
                    components[libgcc]='1'
                    components[libcpp]='1'
                    ;;

                'gdb' )

                    components[gdb]='1'
                    ;;

            esac
        done
    fi

}


# ---------------------------------------------------------------------------------------
# @brief Prepares helper hash array containing versions of components and libraries
# @requires versions
#    hash array containing pairs {component name}:{name with version}
# ---------------------------------------------------------------------------------------
function prepare_versions() {

    local target

    # Prepare targets' versions
    for target in ${TARGETS[@]}; do
        
        # Skip implicit targets
        case $target in "libc_aux" | "libgcc" | "libcpp" ) continue;; esac
        # Get version
        versions[$target]="${opts[${target}_version]}"
        
    done

    # Prepare toolchain's version
    versions[toolchain]="${opts[gcc_version]}"
    
}


# ---------------------------------------------------------------------------------------
# @brief Prepares helper hash array containing URLs of components and libraries
# @requires urls
#    hash array containing pairs {component name}:{download urls}
# ---------------------------------------------------------------------------------------
function prepare_urls() {

    local target

    # Evaluate targets' URLs
    for target in ${TARGETS[@]}; do

        # Skip implicit targets
        case $target in "libc_aux" | "libgcc" | "libcpp" ) continue;; esac
                
        # Evaluate download URLs with VERSION (substitute 'VERSION' with actual version)
        __LIB_VERSION_=${opts[${target}_version]}; opts[${target}_url]=$( echo "${opts[${target}_url]//VERSION/$__LIB_VERSION_}" )
        # Evaluate download URLs with VERSION (substitute 'V_E_R_S_I_O_N' with actual version string where '.' are replaced with '_')
        __LIB_VERSION_=${opts[${target}_version]//./_}; opts[${target}_url]=$( echo "${opts[${target}_url]//V_E_R_S_I_O_N/$__LIB_VERSION_}" )
        # Prepare components' names
        urls[${target}]="${opts[${target}_url]}"

    done
    
}


# ---------------------------------------------------------------------------------------
# @brief Prepares helper hash array containing names of components taking into account
#    versions info
# @requires names
#    hash array containing pairs {component name}:{name with version}
# ---------------------------------------------------------------------------------------
function prepare_names() {

    local target

    # Prepare targets' names
    for target in ${TARGETS[@]}; do

        # Skip implicit targets
        case $target in "libc_aux" | "libgcc" | "libcpp" ) continue;; esac
        # Get target's name with given version
        names[$target]="${target}-${versions[$target]}"

    done

    # Prepare toolchain's name
    names[toolchain_base]="${opts[basename]}"
    names[toolchain_id]="${opts[target]}"
    
}


# ---------------------------------------------------------------------------------------
# @brief Prepares hash array containing paths to helper directories
# @requires dirs
#    hash array containing pairs {helper name}:{absolute path to folder}
# ---------------------------------------------------------------------------------------
function prepare_dirs() {

    # Generate abspaths
    opts[prefix]=$(to_abs_path ${opts[prefix]})
    opts[basedir]=$(to_abs_path ${opts[basedir]})

    # Change prefix directory to the toolchain-named one
    dirs[prefix]="${opts[prefix]}/${names[toolchain_base]}-${names[toolchain_id]}-${versions[toolchain]}"
    # Prepare documentation folder
    dirs[prefix_doc]="${dirs[prefix]}/share/doc/${opts[basename]}-${opts[target]}"
    # Prepare paths to helper directories
    dirs[download]="${opts[basedir]}/download"
    dirs[package]="${opts[basedir]}/package"
    dirs[src]="${opts[basedir]}/src"
    dirs[build]="${opts[basedir]}/build"
    dirs[install]="${opts[basedir]}/install"
    dirs[install_host]="${opts[basedir]}/install/host"
    dirs[install_target]="${opts[basedir]}/install/target"

    # Make target directory
    mkdir -p ${dirs[prefix]}
    mkdir -p ${dirs[prefix_doc]}
    # Create helper directories
    mkdir -p ${dirs[download]}
    mkdir -p ${dirs[src]}
    mkdir -p ${dirs[build]}
    mkdir -p ${dirs[install]}
    mkdir -p ${dirs[install_host]}
    mkdir -p ${dirs[install_target]}

    local target

    # Prepare targets' directories
    for target in ${TARGETS[@]}; do

        # Skip implicit targets
        case $target in "libc_aux" | "libgcc" | "libcpp" ) continue;; esac
        # Get target's src directory
        dirs[$target]="${dirs[src]}/${names[${target}]}"

    done

}


# ---------------------------------------------------------------------------------------
# @brief Prepares helper hash array containing user-defined flags given for components'
#    configuration/compilation
# @requires config_flags
#    hash array containing pairs {target name}:{config_flags}
# @requires compile_flags
#    hash array containing pairs {target name}:{compile_flags}
# @requires build_env
#    hash array containing pairs {target name}:{build_env}
# ---------------------------------------------------------------------------------------
function prepare_flags() {

    local _set_

    # Prepare targets' flag sets
    for _set_ in ${!FLAGS_SETS[@]}; do
        config_flags[$_set_]=${envs[${_set_}_config_flags]}
        compile_flags[$_set_]=${envs[${_set_}_compile_flags]}
        build_env[$_set_]=${envs[${_set_}_build_env]}
    done
    
}

# ========================================================= Implementation ========================================================= #

function install() {

    # Helper dictionaries
    declare -A components
    declare -a components_list
    declare -A versions
    declare -A urls
    declare -A names
    declare -A dirs
    # Flagss sets
    declare -A config_flags
    declare -A compile_flags
    declare -A build_env

    # Set default version of the libc and downlaod URL
    select_libc
    # Install script's dependencies
    install_dependencies
    # Parse list of components to be built
    parse_components

    # Parse versions strings
    prepare_versions
    # Parse download URLs
    prepare_urls
    # Prepare helper names
    prepare_names
    # Create required directories
    prepare_dirs
    # Parse custom compilation/ocnfiguration flags
    prepare_flags

    local component

    # Build subsequent components
    for component in ${components_list[@]}; do

        # Check if component is to be built
        if [[ ${components[$component]} == '1' ]]; then

            # Wait for user's confirmation to build the next component
            is_var_set opts[autocontinue] || {
                log_info "Press a key to start building of the $component"; read
            }

            log_info "Building $component ..."

            # Get name of the corresponding function
            local build_cmd="build_$component"
            # Build component
            $build_cmd && ret=$? || ret=$?
            
            # Verify result of building
            if [[ "$ret" != "0" ]]; then
                log_error "Failed to build $component"
                return 1
            else
                log_info "${component^} built"
            fi
        
        fi
        
    done

    # Wait for user's confirmation to build the next component
    is_var_set opts[autocontinue] || {
        log_info "Press a key to start build's finalizing"; read
    }

    log_info "Finalizing toolchain build..."
    
    # Finalize build
    build_finalize

    # Verify result of building
    if [[ "$ret" != "0" ]]; then
        log_error "Failed to finalize toolchain build"
        return 1
    else
        log_info "Toolchain built sucesfully"
    fi
}
