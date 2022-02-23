#!/usr/bin/env bash
# ====================================================================================================================================
# @file     install.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:28:20 pm
# @modified Wednesday, 23rd February 2022 2:41:14 am
# @project  bash-utils
# @brief
#    
#    Script installing GCC toolchain's comonents
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash
# Source default definitions library
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/defaults.bash
# Source helper functions
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/helpers.bash

# Source components-builders
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/binutils.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/gcc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/libgcc.bash
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/components/gdb.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs GCC toolchain components from source"

# Arguments' descriptions
declare -A pargs_description=(
    [components]="components to be installed"
)

# Components' description
get_heredoc components_description <<END
    Components:

            all installing all components
       binutils intalling binutild  
            gcc intalling GCC compillers
           libc intalling libc [glibc/newlib/ulibc]
            gdb intalling GDB debugger
END

# Options' descriptions
declare -A opts_description=(

    # General options
    [with_libc]="implementation of the standard library to be compiled"
    [build]="toolchain's build machine"
    [host]="toolchain's host machine"
    [target]="toolchain's target machine"
    [force]=$(echo \
        "If set to non-empty valule, COMPONENTS will be rebuil even if " \
        "it was marked as already built in TOOLCHAIN_BASEDIR directory"
    )
    
    # Directories
    [basename]="prefix of the toolchain's tools"
    [prefix]="insallation prefix of the toolchain"
    [download_dir]="Dowload directory for toolchain's components"
    [basedir]=$(echo                                                             \
        "Base directory for toolchain's components. If provided, script "        \
        "will extract source files to this directory and keep them "             \
        "(in TOOLCHAIN_BASEDIR/component_name directory) for future use "        \
        "to avoid repetition download. At the next run of the script, if "       \
        "the same directory is provided, no download (and possibly extraction) " \
        "of the source files would be required. "                                \
        "Morover script marks builded packages by placing empty files "          \
        "(named '.compiled', '.installed', ...) in the build directories "       \
        "(under $TOOLCHAIN_BASEDIR/build/component_name) of the component. "     \
        "If component's build is requested again (e.g. in situation when "       \
        "the whole toolchain is build again after interrupted build), it "       \
        "will be skipped (as long as build version of the component matches) "   \
        "to avoid an overhead. "                                                 \
        "If TOOLCHAIN_BASEDIR is not set, source files are extracted "           \
        "and build in the TOOLCHAIN_DOWNLOAD_DIR and no check is performed"
    )

    # Versions
    [binutils_version]="version of binutils"
    [gcc_version]="version of GCC compiler"
    [gdb_version]="version of GDB debugger"
    [libc_version]=$(echo \
        "version of libc library (default: $TOOLCHAIN_GLIBC_VERSION [glibc] / " \
        "$TOOLCHAIN_NEWLIB_VERSION [newlib] / $TOOLCHAIN_ULIBC_VERSION [ulibc] )"
    )
    # Utilities versions
    [mpfr_version]="version of MPFR library"
    [gmp_version]="version of GMP library"
    [mpc_version]="version of MPC library"
    [isl_version]="version of ISL library"
    [cloog_version]="version of CLOOG library"
    # Download URLs
    [binutils_url]="download URL of Binutils [not implemented - only default URL available]"
    [gcc_url]="download URL of GCC compiler [not implemented - only default URL available]"
    [gdb_url]="download URL of GDB debugger [not implemented - only default URL available]"
    [libc_url]=$(echo \
        "download URL of libc library (default: $TOOLCHAIN_GLIBC_URL_SCHEME [glibc] / " \
        "$TOOLCHAIN_NEWLIB_URL_SCHEME [newlib] / $TOOLCHAIN_ULIBC_URL_SCHEME [ulibc] )" \
        "[not implemented - only default URL available]"
    )
    # Download URLs (utilities)
    [mpfr_url]="download URL of MPFR library [not implemented - only default URL available]"
    [gmp_url]="download URL of GMP library [not implemented - only default URL available]"
    [mpc_url]="download URL of MPC library [not implemented - only default URL available]"
    [isl_url]="download URL of ISL library [not implemented - only default URL available]"
    [cloog_url]="download URL of CLOOG library [not implemented - only default URL available]"
    
)

# Envs' descriptions
declare -A envs_description=(
    [binutils_flags]="name of the array containing additional flags to be passed at compile time of binutils"
    [gcc_flags]="name of the array containing additional flags to be passed at compile time of GCC compiler"
    [libgcc_flags]="name of the array containing additional flags to be passed at compile time of libgcc library"
    [libc_flags]="name of the array containing additional flags to be passed at compile time of libc library"
    [gdb_flags]="name of the array containing additional flags to be passed at compile time of GDB debugger"
)

# ====================================================== Default configuration ===================================================== #

# Logging context of the script
declare LOG_CONTEXT="gcc-toolchain"

# ============================================================ Functions =========================================================== #

function install() {

    # ---------------------------- Installing dependencies ------------------------------

    # Dependencies
    local -a dependencies=(
        build-essential
        wget
    )

    # Install dependencies
    install_pkg_list --su -y -v -U dependencies || {
        log_error "Could not install required dependencies"
        return 1
    }

    # ------------------------------- Parse components ----------------------------------

    # Prepare list of components to be built
    local -A components_to_build=(
        [binutils]='0'
        [gcc]='0'
        [libc]='0'
        [libgcc]='0'
        [gdb]='0'
    )

    # If no components given enable all to be built
    if is_var_set pargs[components]; then
        components_to_build[binutils]='1'
        components_to_build[gcc]='1'
        components_to_build[libc]='1'
        components_to_build[libgcc]='1'
        components_to_build[gdb]='1'
    # Otherwise check what components should e build
    else

        # Iterate over components and check which should be built
        for comp in ${pargs[@]}; do
            case $comp in
                'all' )

                    components_to_build[binutils]='1'
                    components_to_build[gcc]='1'
                    components_to_build[libc]='1'
                    components_to_build[libgcc]='1'
                    components_to_build[gdb]='1'
                    break
                    ;;

                'binutils' )

                    components_to_build[binutils]='1'
                    ;;

                'gcc' )

                    components_to_build[gcc]='1'
                    ;;

                'libc' )

                    components_to_build[libc]='1'
                    components_to_build[libgcc]='1'
                    ;;

                'gdb' )

                    components_to_build[gdb]='1'
                    ;;

            esac
        done
    fi

    # ----------------------------- Process installation --------------------------------

    # Create required directories
    mkdir -p ${opts[prefix]}
    mkdir -p ${opts[download_dir]}
    mkdir -p ${opts[basedir]}

    # Prepare list of components to be built (in order)
    local -a components=(
        binutils
        gcc
        libc
        libgcc
        gdb
    )

    # Build subsequent components
    for component in ${components[@]}; do

        # Check if component is to be built
        if [[ ${components_to_build[$component]} == '1' ]]; then

            # Wait for user's confirmation to build the next component
            log_info "Press a key to start building of the $component"; read

            log_info "Building $component ..."

            # Get name of the corresponding function
            local build_cmd="build_$component"
            # Build component
            $build_cmd && ret=$? || ret=$?
            
            # Verify result of building
            if [[ "$ret" != "0" ]]; then
                log_error "Failed to build $component"
                exit 1
            else
                log_info "${component^} built"
            fi

        fi
        
    done
}

# ============================================================== Main ============================================================== #

function main() {

    # ============================================== Arguments ============================================= #
    local -A components_parg_def=( 
        [format]="COMPONENTS..."
        [name]="components"
        [type]="s"
        [default]='all'
        [variants]="all | binutils | gcc | libc | gdb"
    )
    
    # =============================================== Options ============================================== #
    local -A        a_with_libc_opt_def=( [format]='--with-libc'        [type]='s' [name]='with_libc'        [default]="glibc" [varians]="glibc | newlib | ulibc" )
    local -A            b_build_opt_def=( [format]='--build'            [type]='s' [name]='build'            [default]="$(get_machine)"                           )
    local -A             c_host_opt_def=( [format]='--host'             [type]='s' [name]='host'             [default]="$(get_machine)"                           )
    local -A           f_target_opt_def=( [format]='--target'           [type]='s' [name]='target'           [default]="$(get_machine)"                           )
    local -A            e_force_opt_def=( [format]='--force'            [type]='f' [name]='force'                                                                 )
    local -A         f_basename_opt_def=( [format]='--basename'         [type]='s' [name]='basename'         [default]="gcc"                                      )
    local -A           g_prefix_opt_def=( [format]='--prefix'           [type]='s' [name]='prefix'           [default]="."                                        )
    local -A     h_download_dir_opt_def=( [format]='--download-dir'     [type]='s' [name]='download_dir'     [default]="."                                        )
    local -A          i_basedir_opt_def=( [format]='--basedir'          [type]='s' [name]='basedir'          [default]="."                                        )
    local -A j_binutils_version_opt_def=( [format]='--binutils-version' [type]='s' [name]='binutils_version' [default]="$TOOLCHAIN_BINUTILS_VERSION"              )
    local -A      k_gcc_version_opt_def=( [format]='--gcc-version'      [type]='s' [name]='gcc_version'      [default]="$TOOLCHAIN_GCC_VERSION"                   )
    local -A     l_libc_version_opt_def=( [format]='--libc-version'     [type]='s' [name]='libc_version'                                                          )
    local -A      m_gdb_version_opt_def=( [format]='--gdb-version'      [type]='s' [name]='gdb_version'      [default]="$TOOLCHAIN_GDB_VERSION"                   )
    local -A     n_mpfr_version_opt_def=( [format]='--mpfr-version'                [name]='mpfr_version'     [default]="$TOOLCHAIN_MPFR_VERSION"                  )
    local -A      o_gmp_version_opt_def=( [format]='--gmp-version'                 [name]='gmp_version'      [default]="$TOOLCHAIN_GMP_VERSION"                   )
    local -A      p_mpc_version_opt_def=( [format]='--mpc-version'                 [name]='mpc_version'      [default]="$TOOLCHAIN_MPC_VERSION"                   )
    local -A      r_isl_version_opt_def=( [format]='--isl-version'                 [name]='isl_version'      [default]="$TOOLCHAIN_ISL_VERSION"                   )
    local -A    q_cloog_version_opt_def=( [format]='--cloog-version'               [name]='cloog_version'    [default]="$TOOLCHAIN_CLOOG_VERSION"                 )
    local -A     s_binutils_url_opt_def=( [format]='--binutils-url'                [name]='binutils_url'     [default]="$TOOLCHAIN_BINUTILS_URL_SCHEME"           )
    local -A          t_gcc_url_opt_def=( [format]='--gcc-url'                     [name]='gcc_url'          [default]="$TOOLCHAIN_GCC_URL_SCHEME"                )
    local -A         u_libc_url_opt_def=( [format]='--libc-url'                    [name]='libc_url'                                                              )
    local -A          w_gdb_url_opt_def=( [format]='--gdb-url'                     [name]='gdb_url'          [default]="$TOOLCHAIN_GDB_URL_SCHEME"                )
    local -A         c_mpfr_url_opt_def=( [format]='--mpfr-url'                    [name]='mpfr_url'         [default]="$TOOLCHAIN_MPFR_URL_SCHEME"               )
    local -A          x_gmp_url_opt_def=( [format]='--gmp-url'                     [name]='gmp_url'          [default]="$TOOLCHAIN_GMP_URL_SCHEME"                )
    local -A          y_mpc_url_opt_def=( [format]='--mpc-url'                     [name]='mpc_url'          [default]="$TOOLCHAIN_MPC_URL_SCHEME"                )
    local -A          z_isl_url_opt_def=( [format]='--isl-url'                     [name]='isl_url'          [default]="$TOOLCHAIN_ISL_URL_SCHEME"                )
    local -A       zz_cloog_url_opt_def=( [format]='--cloog-url'                   [name]='cloog_url'        [default]="$TOOLCHAIN_CLOOG_URL_SCHEME"              )

    # ========================================== Envs' definitions ========================================= #
    local -A   c_mpfr_url_env_def=( [format]='TOOLCHAIN_BINUTILS_FLAGS' [name]='binutils_flags' )
    local -A    x_gmp_url_env_def=( [format]='TOOLCHAIN_GCC_FLAGS'      [name]='gcc_flags'      )
    local -A    y_mpc_url_env_def=( [format]='TOOLCHAIN_LIBGCC_FLAGS'   [name]='libgcc_flags'   )
    local -A    z_isl_url_env_def=( [format]='TOOLCHAIN_LIBC_FLAGS'     [name]='libc_flags'     )
    local -A zz_cloog_url_env_def=( [format]='TOOLCHAIN_GDB_FLAGS'      [name]='gdb_flags'      )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=135
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )

    # Parse arguments
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi

    # Convert paths to absolute
    opts[prefix]=$(realpath ${opts[prefix]})
    opts[download_dir]=$(realpath ${opts[download_dir]})
    opts[basedir]=$(realpath ${opts[basedir]})
    # Set default version of the libc and downlaod URL
    is_var_set opts[libc_version] || opts[libc_version]=$(get_default_libc_version ${opts[with_libc]})
    is_var_set opts[libc_url]     || opts[libc_url]=$(get_default_libc_url ${opts[with_libc]})

    # Evaluate download URLs for components
    __LIB_VERSION_=${opts[binutils_version]}; opts[binutils_url]=$( echo "${opts[binutils_url]//VERSION/$__LIB_VERSION_}" )
    __LIB_VERSION_=${opts[gcc_version]};      opts[gcc_url]=$(      echo "${opts[gcc_url]//VERSION/$__LIB_VERSION_}"      )
    __LIB_VERSION_=${opts[libc_version]};     opts[libc_url]=$(     echo "${opts[libc_url]//VERSION/$__LIB_VERSION_}"     )
    __LIB_VERSION_=${opts[gdb_version]};      opts[gdb_url]=$(      echo "${opts[gdb_url]//VERSION/$__LIB_VERSION_}"      )
    # Evaluate download URLs for libraries
    __LIB_VERSION_=${opts[mpfr_version]};     opts[mpfr_url]=$(     echo "${opts[mpfr_url]//VERSION/$__LIB_VERSION_}"     )
    __LIB_VERSION_=${opts[gmp_version]};      opts[gmp_url]=$(      echo "${opts[gmp_url]//VERSION/$__LIB_VERSION_}"      )
    __LIB_VERSION_=${opts[mpc_version]};      opts[mpc_url]=$(      echo "${opts[mpc_url]//VERSION/$__LIB_VERSION_}"      )
    __LIB_VERSION_=${opts[isl_version]};      opts[isl_url]=$(      echo "${opts[isl_url]//VERSION/$__LIB_VERSION_}"      )
    __LIB_VERSION_=${opts[cloog_version]};    opts[cloog_url]=$(    echo "${opts[cloog_url]//VERSION/$__LIB_VERSION_}"    )

    # Set default flags' sets
    is_var_set envs[binutils_flags] || envs[binutils_flags]='TOOLCHAIN_BINUTILS_DEFAULT_FLAGS'
    is_var_set envs[gcc_flags]      || envs[gcc_flags]='TOOLCHAIN_GCC_DEFAULT_FLAGS'
    is_var_set envs[libgcc_flags]   || envs[libgcc_flags]='TOOLCHAIN_LIBGCC_DEFAULT_FLAGS'
    is_var_set envs[libc_flags]     || envs[libc_flags]='TOOLCHAIN_LIBC_DEFAULT_FLAGS'
    is_var_set envs[gdb_flags]      || envs[gdb_flags]='TOOLCHAIN_GDB_DEFAULT_FLAGS'

    # Proceede installation
    install
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

