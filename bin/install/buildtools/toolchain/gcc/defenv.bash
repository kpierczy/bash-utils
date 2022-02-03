#!/usr/bin/env bash
# ====================================================================================================================================
# @file     defenv.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 7th November 2021 3:08:11 pm
# @modified Sunday, 7th November 2021 3:08:43 pm
# @project  bash-utils
# @brief
#    
#    Default environment variables for GCC toolchain builtool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Components' version
var_set_default TOOLCHAIN_BINUTILS_VERSION "2.37"
var_set_default TOOLCHAIN_GCC_VERSION      "11.2.0"
var_set_default TOOLCHAIN_GLIBC_VERSION    "2.34"
var_set_default TOOLCHAIN_NEWLIB_VERSION   "4.1.0"
var_set_default TOOLCHAIN_GDB_VERSION      "11.1"

# Build machine
var_set_default TOOLCHAIN_BUILD ""
# Host machine
var_set_default TOOLCHAIN_HOST ""
# Target machine
var_set_default TOOLCHAIN_TARGET ""
# Toolchain's prefix
var_set_default TOOLCHAIN_BASENAME ""
# Tolchain's installation directory
var_set_default TOOLCHAIN_PREFIX "."

# Version of libraries
var_set_default TOOLCHAIN_MPFR_VERSION   "4.1.0"
var_set_default TOOLCHAIN_GMP_VERSION    "6.2.1"
var_set_default TOOLCHAIN_MPC_VERSION    "1.2.1"
var_set_default TOOLCHAIN_ISL_VERSION    "0.18"
var_set_default TOOLCHAIN_CLOOG_VERSION  "0.18.1"

# Additional compilation flags
var_set_default TOOLCHAIN_BINUTILS_FLAGS ""
var_set_default TOOLCHAIN_GCC_FLAGS      ""
var_set_default TOOLCHAIN_LIBGCC_FLAGS   ""
var_set_default TOOLCHAIN_GLIBC_FLAGS    ""
var_set_default TOOLCHAIN_GDB_FLAGS      ""

# Download links for components and libraries
var_set_default TOOLCHAIN_BINUTILS_URL "https://ftp.gnu.org/gnu/binutils/binutils-$TOOLCHAIN_BINUTILS_VERSION.tar.gz"
var_set_default TOOLCHAIN_GCC_URL      "https://ftp.gnu.org/gnu/gcc/gcc-$TOOLCHAIN_GCC_VERSION/gcc-$TOOLCHAIN_GCC_VERSION.tar.gz"
var_set_default TOOLCHAIN_GLIBC_URL    "https://ftp.gnu.org/gnu/glibc/glibc-$TOOLCHAIN_GLIBC_VERSION.tar.gz"
var_set_default TOOLCHAIN_NEWLIB_URL   "ftp://sourceware.org/pub/newlib/newlib-$TOOLCHAIN_NEWLIB_VERSION.tar.gz"
var_set_default TOOLCHAIN_GDB_URL      "https://ftp.gnu.org/gnu/gdb/gdb-$TOOLCHAIN_GDB_VERSION.tar.gz"

var_set_default TOOLCHAIN_MPFR_URL     "https://ftp.gnu.org/gnu/mpfr/mpfr-$TOOLCHAIN_MPFR_VERSION.tar.gz"
var_set_default TOOLCHAIN_GMP_URL      "https://ftp.gnu.org/gnu/gmp/gmp-$TOOLCHAIN_GMP_VERSION.tar.bz2"
var_set_default TOOLCHAIN_MPC_URL      "https://ftp.gnu.org/gnu/mpc/mpc-$TOOLCHAIN_MPC_VERSION.tar.gz"
var_set_default TOOLCHAIN_ISL_URL      "https://gcc.gnu.org/pub/gcc/infrastructure/isl-$TOOLCHAIN_ISL_VERSION.tar.bz2"
var_set_default TOOLCHAIN_CLOOG_URL    "https://gcc.gnu.org/pub/gcc/infrastructure/cloog-$TOOLCHAIN_CLOOG_VERSION.tar.gz"

# Additional configuration
var_set_default TOOLCHAIN_DOWNLOAD_DIR "/tmp"
var_set_default TOOLCHAIN_BASEDIR      ""
var_set_default TOOLCHAIN_FORCE_REBUID ""
