#!/usr/bin/env bash
# ====================================================================================================================================
# @file     defaults.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 7th November 2021 3:08:11 pm
# @modified Friday, 25th February 2022 1:31:32 pm
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
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/prerequisites.bash
# Source components-builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/binutils.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/gcc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/libc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/libgcc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/libcpp.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/gdb.bash
# Source build finalizer
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/priv/components/finalize.bash

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
    elfutils
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

        # Copied from ARM Embedded toolchain
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
        # Dependcies of 'elfutils'
        libarchive-dev
        libmicrohttpd-dev
        zstd
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

        # Depending ont he target
        case $target in 
            
            # Skip implicit targets
            "libc_aux" | "libgcc" | "libcpp" ) continue;; 

            # For other targets get target's name with given version
            *) names[$target]="${target}-${versions[$target]}" ;;

        esac

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
    dirs[basedir]="${opts[basedir]}"
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

# ---------------------------------------------------------------------------------------
# @brief Compiles comma-separated list of components to be build by the script
#
# @requires components
#    hash array containing names of components associated with either '1' or '0'
#    depending on whether the component needs to be built or not respectively
# @requires components_list
#    array containing names of components IN ORDER
#
# @outputs
#     compiled list
# ---------------------------------------------------------------------------------------
function get_components_list() {

    # Initialize output
    local result=""

    local comp

    # Iterate over components
    for comp in ${components_list[@]}; do
        if [[ ${components[$comp]} == '1' ]]; then
            result+="$comp, "
        fi
    done
    
    # Remove trailing comma
    if [[ ${#result} != "0" ]]; then
        result=${result::-2}
    fi

    # Output result
    echo $result
}


# ---------------------------------------------------------------------------------------
# @brief Prints summary of the build to be conducted to the user
# ---------------------------------------------------------------------------------------
function print_build_info() {

    local comp

    # Print list of components to be built
    log_info "Building: $(set_bold)$(get_components_list)$(reset_colors)"
    # Print folders info
    log_info "Installation directory: $(set_bold)${dirs[prefix]}$(reset_colors)"
    log_info "Working directory: $(set_bold)${dirs[basedir]}$(reset_colors)"

    # Print versions info
    log info "Versions:"
    # Print dependencies' versions
    [[ ${components[prerequisites]} == '1' ]] && {
        log info "    - dependencies:"
        log info "        - zlib: $(set_bold)$(set_fblue)${versions[zlib]}$(reset_colors)"
        log info "        - gmp: $(set_bold)$(set_fblue)${versions[gmp]}$(reset_colors)"
        log info "        - mpfr: $(set_bold)$(set_fblue)${versions[mpfr]}$(reset_colors)"
        log info "        - mpc: $(set_bold)$(set_fblue)${versions[mpc]}$(reset_colors)"
        log info "        - isl: $(set_bold)$(set_fblue)${versions[isl]}$(reset_colors)"
        log info "        - elfutils: $(set_bold)$(set_fblue)${versions[elfutils]}$(reset_colors)"
        log info "        - expat: $(set_bold)$(set_fblue)${versions[expat]}$(reset_colors)"
        log info "        - cloog: $(set_bold)$(set_fblue)${versions[cloog]}$(reset_colors)"
    }
    # Print components versions
    for comp in ${components_list[@]}; do
        if [[ ${components[$comp]} == '1' ]]; then

            local comp_name

            # For libc, add implementation
            [[ $comp == 'libc' ]] &&
                comp_name="$comp (${opts[with_libc]})" ||
                comp_name="$comp"
            # Print components' versions
            case $comp in
                'prerequisites' | 'libgcc' | 'libcpp' ) ;;
                * ) log info "    - $comp_name: $(set_bold)$(set_fgreen)${versions[$comp]}$(reset_colors)" ;;
            esac
        fi
    done

    # Prin whether build is forced
    is_var_set opts[force] &&
        log_info "Build type: $(set_bold)$(set_blue)forced$(reset_colors)" ||
        log_info "Build type: $(set_bold)default$(reset_colors)"
    # Prin whether documentation is built
    is_var_set opts[with_doc] &&
        log_info "Building documentation: $(set_bold)$(set_fblue)yes$(reset_colors)" ||
        log_info "Building documentation: $(set_bold)no$(reset_colors)"

    log_info
}

# ---------------------------------------------------------------------------------------
# @brief Helper predicate function selecting environmental variables required for the 
#    build
# 
# @returns
#   @retval @c 0 if variable is not needed
#   @retval @c 1 otherwise
# ---------------------------------------------------------------------------------------
function is_variable_useless_for_build() {

    # Arguments
    local var="$1"

    # Choose variables to keep
    case "$var" in

        # 1st category [2]
        WORKSPACE | SRC_VERSION ) return 1 ;;
        # 2nd category [2]
        DEJAGNU | DISPLAY | HOME | LD_LIBRARY_PATH | LOGNAME | PATH | PWD | SHELL | SHLVL | TERM | USER | USERNAME | XAUTHORITY ) return 1 ;;
        # 3rd category [2]
        com.apple.* ) return 1 ;;
        # 4th category [2]
        LSB_* | LSF_* | LS_* | EGO_* | HOSTTYPE | TMPDIR ) return 1 ;;
        # Others (discard)
        * ) return 0 ;;
        
    esac

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

    # Evaluate `eval` string to possibly inject some entities into the script's namespace
    eval "${envs[eval_string]}"

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

    # Print build informations
    print_build_info
    # Clear environment
    clean_env 'is_variable_useless_for_build'
    export LANG=C
    local component
    
    # Build subsequent components
    for component in ${components_list[@]}; do

        # Check if component is to be built
        if [[ ${components[$component]} == '1' ]]; then

            # Wait for user's confirmation to build the next component
            is_var_set opts[autocontinue] || {
                log_info "$(set_bold)Press a key to start building of the $(set_fgreen)$component$(reset_colors)"; read -s
            }

            log_info "Building $component..."

            # Get name of the corresponding function
            local build_cmd="build_$component"
            # Build component
            $build_cmd && ret=$? || ret=$?
            
            # Verify result of building
            if [[ "$ret" != "0" ]]; then
                log_error "Failed to build $component"
                return 1
            else
                log_info "$(set_bold)$(set_fgreen)${component^}$(set_fdefault) built$(reset_colors)"
            fi
        
        fi
        
    done

    # Wait for user's confirmation to build the next component
    is_var_set opts[autocontinue] || {
        log_info "$(set_bold)Press a key to start build's finalizing$(reset_colors)"; read -s
    }

    log_info "Finalizing toolchain build..."
    
    # Finalize build
    build_finalize && ret=$? || ret=$?

    # Verify result of building
    if [[ "$ret" != "0" ]]; then
        log_error "Failed to finalize toolchain build"
        return 1
    else
        log_info "Toolchain built sucesfully"
    fi
}
