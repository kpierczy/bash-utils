#!/usr/bin/env bash
# ====================================================================================================================================
# @file     gcc-arm-none-eabi.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 6:16:17 pm
# @modified Thursday, 24th February 2022 6:11:19 am
# @project  bash-utils
# @brief
#    
#    Installs arm-none-eabi toolchain form source (abased on the build script from ARM Embedded Toolchain v10.3-2021.10)
#    
# @copyright Krzysztof Pierczyk © 2021
# @see https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-src.tar.bz2
# ====================================================================================================================================

# Source bash-utils library
source $BASH_UTILS_HOME/source_me.bash
# Source defaults of the toolchain's builder
source $BASH_UTILS_HOME/bin/install/buildtools/toolchain/gcc/defaults.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs arm-none-eabi toolchain form source"

# Options' descriptions
declare -A opts_description=(
    [prefix]="installation directory"
    [basedir]="basedire directory for toolchain's builder"
    [debug]="if set, the debug build will be used"
)

# ====================================================== Common configruation ====================================================== #

# Logging context of the script
declare LOG_CONTEXT="gcc-arm-none-eabi"

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Copies newlib-nano's multilib from build to the installation directory
#
# @param src_prefix
#    prefix of the source directory
# @param dst_prefix
#    prefix of the destination directory
# @param target_gcc
#    `gcc` binary used to list multilibs
# ---------------------------------------------------------------------------------------
function copy_multi_libs() {

    # Arguments (replace spaces with '\\ ')
    local src_prefix="${1// /\\ }"
    local dst_prefix="${2// /\\ }"
    local target_gcc="${3// /\\ }"

    # Get list of multilibs
    local -a multilibs=( $("${target_gcc}" -print-multi-lib 2>/dev/null) )
    
    local multilib

    # Iterate over multilibs to be copied
    for multilib in "${multilibs[@]}" ; do

        # Compute name of the lib's directory
        local multi_dir="${multilib%%;*}"
        # Compute names of src and dst directories
        local src_dir=${src_prefix}/${multi_dir}
        local dst_dir=${dst_prefix}/${multi_dir}

        # Copy content of the lib
        cp -f "${src_dir}/libstdc++.a"  "${dst_dir}/libstdc++_nano.a"
        cp -f "${src_dir}/libsupc++.a"  "${dst_dir}/libsupc++_nano.a"
        cp -f "${src_dir}/libc.a"       "${dst_dir}/libc_nano.a"
        cp -f "${src_dir}/libg.a"       "${dst_dir}/libg_nano.a"
        cp -f "${src_dir}/librdimon.a"  "${dst_dir}/librdimon_nano.a"
        cp -f "${src_dir}/nano.specs"   "${dst_dir}/"
        cp -f "${src_dir}/rdimon.specs" "${dst_dir}/"
        cp -f "${src_dir}/nosys.specs"  "${dst_dir}/"
        cp -f "${src_dir}/"*crt0.o      "${dst_dir}/"
        
    done
}

# ============================================================== Main ============================================================== #

function install() {

    # ------------------------- Prepare helper configuration ----------------------------

    # Multilib list
    declare MULTILIB_LIST
    MULTILIB_LIST+=" --with-multilib-list=rmprofile"

    # Common GCC flags
    declare GCC_CONFIG
    GCC_CONFIG+=" --with-host-libstdcxx=-static-libgcc"
    GCC_CONFIG+=" -Wl,-Bstatic,-lstdc++,-Bdynamic"
    GCC_CONFIG+=" -lm"
    
    # Build version string
    declare PKG_VERSION="GNU Arm Embedded Toolchain $TOOLCHAIN_GCC_VERSION"

    # Build options
    declare BUILD_OPTIONS=
    # Debug build options
    is_var_set opts[debug] && {
        BUILD_OPTIONS+=" -g"
        BUILD_OPTIONS+=" -O0"
    }
    
    # Additional build options (unused at the moment)
    declare AUX_BUILD_OPTIONS
    AUX_BUILD_OPTIONS+=" -fbracket-depth=512"

    # Helper C flags
    declare ENV_CFLAGS
    ENV_CFLAGS+=" -I${opts[basedir]}/install/host/zlib/include"
    ENV_CFLAGS+=" $BUILD_OPTIONS"
    # Helper C flags
    declare ENV_CPPFLAGS
    ENV_CPPFLAGS+=" -I${opts[basedir]}/install/host/zlib/include"
    # Helper linker flags
    declare ENV_LDFLAGS
    ENV_LDFLAGS+=" -L${opts[basedir]}/install/host/zlib/lib"
    ENV_LDFLAGS+=" -L${opts[basedir]}/install/host/usr/lib"

    # ------------------------- Prepare common configuration ----------------------------

    # Common compile flags
    declare TOOLCHAIN_COMPILE_FLAGS="-j 8"

    # --------------------------- Libraries' configuration ------------------------------

    # Zlib configruation
    declare TOOLCHAIN_ZLIB_CONFIG_FLAGS
    TOOLCHAIN_ZLIB_CONFIG_FLAGS+="--static"
    
    # GMP configuration
    declare TOOLCHAIN_GMP_CONFIG_FLAGS
    TOOLCHAIN_GMP_CONFIG_FLAGS+=" --enable-cxx"
    TOOLCHAIN_GMP_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_GMP_CONFIG_FLAGS+=" --disable-nls"
    declare -A GMP_BUILD_ENV
    GMP_BUILD_ENV['CPPFLAGS']="-fexceptions"
    declare TOOLCHAIN_GMP_BUILD_ENV='GMP_BUILD_ENV'

    # MPFR configuration
    declare TOOLCHAIN_MPFR_CONFIG_FLAGS
    TOOLCHAIN_MPFR_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_MPFR_CONFIG_FLAGS+=" --disable-nls"

    # MPC configuration
    declare TOOLCHAIN_MPC_CONFIG_FLAGS
    TOOLCHAIN_MPC_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_MPC_CONFIG_FLAGS+=" --disable-nls"

    # ISL configuration
    declare TOOLCHAIN_ISL_CONFIG_FLAGS
    TOOLCHAIN_ISL_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_ISL_CONFIG_FLAGS+=" --disable-nls"

    # Libelf configruation
    declare TOOLCHAIN_LIBELF_CONFIG_FLAGS
    TOOLCHAIN_LIBELF_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_LIBELF_CONFIG_FLAGS+=" --disable-nls"

    # Expat configruation
    declare TOOLCHAIN_EXPAT_CONFIG_FLAGS
    TOOLCHAIN_EXPAT_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_EXPAT_CONFIG_FLAGS+=" --disable-nls"

    # Cloog configruation
    declare TOOLCHAIN_CLOOG_CONFIG_FLAGS
    TOOLCHAIN_CLOOG_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_CLOOG_CONFIG_FLAGS+=" --disable-nls"

    # --------------------------- Components configuration ------------------------------

    # Configuration of the binutils
    declare TOOLCHAIN_BINUTILS_CONFIG_FLAGS
    CONFIG_BINUTILS_FLAGS+=" --disable-nls"
    CONFIG_BINUTILS_FLAGS+=" --disable-werror"
    CONFIG_BINUTILS_FLAGS+=" --disable-sim"
    CONFIG_BINUTILS_FLAGS+=" --disable-gdb"
    CONFIG_BINUTILS_FLAGS+=" --enable-interwork"
    CONFIG_BINUTILS_FLAGS+=" --enable-plugins"
    CONFIG_BINUTILS_FLAGS+=" --with-pkgversion=$PKG_VERSION"
    declare -A BINUTILS_BUILD_ENV
    BINUTILS_BUILD_ENV['CFLAGS']="$ENV_CFLAGS"
    BINUTILS_BUILD_ENV['CPPFLAGS']="$ENV_CPPFLAGS"
    BINUTILS_BUILD_ENV['DFLAGS']="$ENV_LDFLAGS"
    declare TOOLCHAIN_BINUTILS_BUILD_ENV='BINUTILS_BUILD_ENV'

    # Configuration of the gcc
    declare TOOLCHAIN_GCC_CONFIG_FLAGS
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --enable-languages=c"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-decimal-float"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-libffi"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-libgomp"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-libmudflap"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-libquadmath"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-libssp"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-libstdcxx-pch"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-nls"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-threads"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --disable-tls"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --with-newlib"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --without-headers"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --with-gnu-as"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" --with-gnu-ld"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" -with-pkgversion=$PKG_VERSION"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" $GCC_CONFIG"
    TOOLCHAIN_GCC_CONFIG_FLAGS+=" $MULTILIB_LIST"

    # Configuration of the libc (newlib)
    declare TOOLCHAIN_LIBC_CONFIG_FLAGS
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --enable-newlib-io-long-long"
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --enable-newlib-io-c99-formats"
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --enable-newlib-reent-check-verify"
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --enable-newlib-register-fini"
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --enable-newlib-retargetable-locking"
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --disable-newlib-supplied-syscalls"
    TOOLCHAIN_LIBC_CONFIG_FLAGS+=" --disable-nls"
    declare -A LIBC_BUILD_ENV
    LIBC_BUILD_ENV['CFLAGS_FOR_TARGET']=""
    LIBC_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -ffunction-sections"
    LIBC_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -fdata-sections"
    LIBC_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -O2"
    is_var_set opts[debug] &&
        LIBC_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -g"
    declare TOOLCHAIN_LIBC_BUILD_ENV='LIBC_BUILD_ENV'

    # Configuration of the auxiliary libc (newlib nano)
    declare TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --disable-newlib-supplied-syscalls"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-newlib-reent-check-verify"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-newlib-reent-small"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-newlib-retargetable-locking"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --disable-newlib-fvwrite-in-streamio"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --disable-newlib-fseek-optimization"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --disable-newlib-wide-orient"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-newlib-nano-malloc"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --disable-newlib-unbuf-stream-opt"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-lite-exit"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-newlib-global-atexit"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --enable-newlib-nano-formatted-io"
    TOOLCHAIN_LIBC_AUX_CONFIG_FLAGS+=" --disable-nls"
    declare -A LIBC_AUX_BUILD_ENV
    LIBC_AUX_BUILD_ENV['CFLAGS_FOR_TARGET']=""
    LIBC_AUX_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -ffunction-sections"
    LIBC_AUX_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -fdata-sections"
    LIBC_AUX_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -O2"
    is_var_set opts[debug] &&
        LIBC_AUX_BUILD_ENV['CFLAGS_FOR_TARGET']+=" -g"
    declare TOOLCHAIN_LIBC_AUX_BUILD_ENV='LIBC_AUX_BUILD_ENV'

    # Configuration of the libgcc
    declare TOOLCHAIN_LIBGCC_CONFIG_FLAGS
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --enable-languages=c,c++"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --enable-plugins"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-decimal-float"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-libffi"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-libgomp"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-libmudflap"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-libquadmath"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-libssp"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-libstdcxx-pch"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-nls"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-threads"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --disable-tls"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --with-gnu-as"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --with-gnu-ld"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --with-newlib"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --with-headers=yes"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" $GCC_CONFIG"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" --with-pkgversion=$PKG_VERSION"
    TOOLCHAIN_LIBGCC_CONFIG_FLAGS+=" $MULTILIB_LIST"
    # @note Originally these flags was passed directly to `make`
    declare -A LIBGCC_BUILD_ENV
    LIBGCC_BUILD_ENV['CXXFLAGS']="$BUILD_OPTIONS"
    LIBGCC_BUILD_ENV['INHIBIT_LIBC_CFLAGS']="-DUSE_TM_CLONE_REGISTRY=0"
    declare TOOLCHAIN_LIBGCC_BUILD_ENV='LIBGCC_BUILD_ENV'

    # ----------------------------------------------------------------------
    # @note [INHIBIT_LIBC_CFLAGS] variable is set to disable transactional 
    #     memory related code in crtbegin.o. This is a workaround. Better
    #     approach is have a t-* to set this flag via CRTSTUFF_T_CFLAGS
    # ----------------------------------------------------------------------

    # Configuration of the libcpp
    declare TOOLCHAIN_LIBCPP_CONFIG_FLAGS
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --enable-languages=c,c++"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-decimal-float"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libffi"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libgomp"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libmudflap"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libquadmath"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libssp"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libstdcxx-pch"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-libstdcxx-verbose"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-nls"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-shared"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-threads"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --disable-tls"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --with-gnu-as"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --with-gnu-ld"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --with-newlib"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --with-headers=yes"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" $GCC_CONFIG"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" --with-pkgversion=$PKG_VERSION"
    TOOLCHAIN_LIBCPP_CONFIG_FLAGS+=" $MULTILIB_LIST"
    # @note Originally these flags was passed directly to `make`
    declare -A LIBCPP_BUILD_ENV
    LIBCPP_BUILD_ENV['CXXFLAGS']="$BUILD_OPTIONS"
    LIBCPP_BUILD_ENV['CXXFLAGS_FOR_TARGET']=""
    LIBCPP_BUILD_ENV['CXXFLAGS_FOR_TARGET']+=" -g"
    LIBCPP_BUILD_ENV['CXXFLAGS_FOR_TARGET']+=" -Os"
    LIBCPP_BUILD_ENV['CXXFLAGS_FOR_TARGET']+=" -ffunction-sections"
    LIBCPP_BUILD_ENV['CXXFLAGS_FOR_TARGET']+=" -fdata-sections"
    LIBCPP_BUILD_ENV['CXXFLAGS_FOR_TARGET']+=" -fno-exceptions"
    declare TOOLCHAIN_LIBCPP_BUILD_ENV='LIBCPP_BUILD_ENV'

    # Configuration of the binutils
    declare TOOLCHAIN_GDB_CONFIG_FLAGS
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --disable-nls"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --disable-sim"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --disable-gas"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --disable-binutils"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --disable-ld"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --disable-gprof"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --with-libexpat"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --with-lzma=no"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --with-gdb-datadir='\''\${prefix}'\''/arm-none-eabi/share/gdb'"
    TOOLCHAIN_GDB_CONFIG_FLAGS+=" --with-pkgversion=$PKG_VERSION"

    # ----------------------------------- Building --------------------------------------
    
    # Install toolchain
    bin/install/buildtools/toolchain/gcc.bash \
        --with-libc='newlib-nano'             \
        --target='arm-none-eabi'              \
        --with-doc                            \
        --prefix=${opts[prefix]}              \
        --basedir=${opts[basedir]}
        
    # ----------------------------------- Finalize --------------------------------------

    # Get destination of the build
    local install_dir="${opts[prefix]}/gcc-arm-none-eabi-$TOOLCHAIN_GCC_VERSION"

    # Copy nano's multilibs into the destination directory
    copy_multi_libs                                                    \
        src_prefix="${opts[basedir]}/install/target/arm-none-eabi/lib" \
        dst_prefix="$install_dir/arm-none-eabi/lib"                    \
        target_gcc="${opts[basedir]}/install/target/bin/arm-none-eabi-gcc"

    # Copy the nano configured `newlib.h` file into the location that `nano.specs` expects it to be
    mkdir -p "$install_dir/arm-none-eabi/include/newlib-nano"
    cp -f "${opts[basedir]}/install/target/arm-none-eabi/include/newlib.h" \
          "$install_dir/arm-none-eabi/include/newlib-nano/newlib.h"

}

# ============================================================== Main ============================================================== #

function main() {


    # Options
    local -A  a_prefix_opt_def=( [format]="--prefix"  [name]="prefix"  [type]="p" [default]="." )
    local -A b_basedir_opt_def=( [format]="--basedir" [name]="basedir" [type]="p" [default]="." )
    local -A   c_debug_opt_def=( [format]="--debug"   [name]="debug"   [type]="f"               )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    local -a PARSEARGS_OPTS
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

    # Run installation routine
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
