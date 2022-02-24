#!/usr/bin/env bash
# ====================================================================================================================================
# @file     defaults.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 7th November 2021 3:08:11 pm
# @modified Thursday, 24th February 2022 6:28:43 am
# @project  bash-utils
# @brief
#    
#    Default environment variables for GCC toolchain builtool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Components' version (defaults)
var_set_default TOOLCHAIN_BINUTILS_VERSION "2.37"
var_set_default TOOLCHAIN_GCC_VERSION      "11.2.0"
var_set_default TOOLCHAIN_GLIBC_VERSION    "2.34"
var_set_default TOOLCHAIN_NEWLIB_VERSION   "4.1.0"
var_set_default TOOLCHAIN_ULIBC_VERSION    "0.9.33.2"
var_set_default TOOLCHAIN_GDB_VERSION      "11.1"
# Version of libraries
var_set_default TOOLCHAIN_ZLIB_VERSION     "1.2.11"
var_set_default TOOLCHAIN_GMP_VERSION      "6.2.1"
var_set_default TOOLCHAIN_MPFR_VERSION     "4.1.0"
var_set_default TOOLCHAIN_MPC_VERSION      "1.2.1"
var_set_default TOOLCHAIN_ISL_VERSION      "0.18"
var_set_default TOOLCHAIN_LIBELF_VERSION   "0.186"
var_set_default TOOLCHAIN_EXPAT_VERSION    "2.4.6"
var_set_default TOOLCHAIN_CLOOG_VERSION    "0.18.1"

# Download links for components
var_set_default TOOLCHAIN_BINUTILS_URL_SCHEME "https://ftp.gnu.org/gnu/binutils/binutils-VERSION.tar.gz"
var_set_default TOOLCHAIN_GCC_URL_SCHEME      "https://ftp.gnu.org/gnu/gcc/gcc-VERSION/gcc-VERSION.tar.gz"
var_set_default TOOLCHAIN_GLIBC_URL_SCHEME    "https://ftp.gnu.org/gnu/glibc/glibc-VERSION.tar.gz"
var_set_default TOOLCHAIN_NEWLIB_URL_SCHEME   "ftp://sourceware.org/pub/newlib/newlib-VERSION.tar.gz"
var_set_default TOOLCHAIN_ULIBC_URL_SCHEME    "https://www.uclibc.org/downloads/uClibc-VERSION.tar.bz2"
var_set_default TOOLCHAIN_GDB_URL_SCHEME      "https://ftp.gnu.org/gnu/gdb/gdb-VERSION.tar.gz"
# Download links for libraries
var_set_default TOOLCHAIN_ZLIB_URL_SCHEME     "https://zlib.net/zlib-VERSION.tar.gz"
var_set_default TOOLCHAIN_GMP_URL_SCHEME      "https://ftp.gnu.org/gnu/gmp/gmp-VERSION.tar.bz2"
var_set_default TOOLCHAIN_MPFR_URL_SCHEME     "https://ftp.gnu.org/gnu/mpfr/mpfr-VERSION.tar.gz"
var_set_default TOOLCHAIN_MPC_URL_SCHEME      "https://ftp.gnu.org/gnu/mpc/mpc-VERSION.tar.gz"
var_set_default TOOLCHAIN_ISL_URL_SCHEME      "https://gcc.gnu.org/pub/gcc/infrastructure/isl-VERSION.tar.bz2"
var_set_default TOOLCHAIN_LIBELF_URL_SCHEME   "https://sourceware.org/elfutils/ftp/VERSION/elfutils-VERSION.tar.bz2"
var_set_default TOOLCHAIN_EXPAT_URL_SCHEME    "https://github.com/libexpat/libexpat/releases/download/R_V_E_R_S_I_O_N/expat-VERSION.tar.gz"
var_set_default TOOLCHAIN_CLOOG_URL_SCHEME    "https://gcc.gnu.org/pub/gcc/infrastructure/cloog-VERSION.tar.gz"

# Empty environment hash-array
declare -A EMPTY_ENV=()
