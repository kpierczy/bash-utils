#!/usr/bin/env bash
# ====================================================================================================================================
# @file     install.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:28:20 pm
# @modified Saturday, 6th November 2021 6:43:10 pm
# @project  BashUtils
# @brief
#    
#    Script installing GCC toolchain's comonents
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs GCC toolchain components
    Usage: gcc.bash TYPE [COMPONENTS...]

    Arguments:

              TYPE  type of the installation to be performed

                      pkg  component(s) will be installed from apt package
                      src  component(s) will be installed from source
        
        COMPONENTS  components to be installed

                      all  installing all components
                 binutils  intalling binutild  
                      gcc  intalling GCC compillers
                    glibc  intalling glibc
                      gdb  intalling GDB debugger

    Options:
      
        --help  displays this usage message

    Environment:

      TOOLCHAIN_BINUTILS_VERSION  Version of binutils      [default: (src) 2.36.1 | (pkg) ]
           TOOLCHAIN_GCC_VERSION  Version of GCC compiler  [default: (src) 11.2.0 | (pkg) ]
         TOOLCHAIN_GLIBC_VERSION  Version of glibc library [default: (src) 2.34   | (pkg) ]
           TOOLCHAIN_GDB_VERSION  Version of GDB debugger  [default: (src) 11.1   | (pkg) ]

    Environment (source build only):

                 TOOLCHAIN_BUILD  toolchain's build machine [default: current platform]
                  TOOLCHAIN_HOST  toolchain's host machine [default: current platform]
                TOOLCHAIN_TARGET  toolchain's host machine [default: current platform]
              TOOLCHAIN_BASENAME  prefix of the toolchain's tools [default: '']
                TOOLCHAIN_PREFIX  insallation prefix of the toolchain [default: .] 

          TOOLCHAIN_MPFR_VERSION  Version of MPFR library   [default: 4.1.0 ]
           TOOLCHAIN_GMP_VERSION  Version of GMP library    [default: 6.2.1 ]
           TOOLCHAIN_MPC_VERSION  Version of MPC library    [default: 1.2.1 ]
           TOOLCHAIN_ISL_VERSION  Version of ISL library    [default: 0.18  ]
         TOOLCHAIN_CLOOG_VERSION  Version of CLOOG library  [default: 0.18.1]

        TOOLCHAIN_BINUTILS_FLAGS  Additional flags to be passed at compile time of binutils
             TOOLCHAIN_GCC_FLAGS  Additional flags to be passed at compile time of GCC compiler
          TOOLCHAIN_LIBGCC_FLAGS  Additional flags to be passed at compile time of libgcc library
           TOOLCHAIN_GLIBC_FLAGS  Additional flags to be passed at compile time of glibc library
             TOOLCHAIN_GDB_FLAGS  Additional flags to be passed at compile time of GDB debugger 

          TOOLCHAIN_BINUTILS_URL  URL for downloading Binutils       [default URL provided]
               TOOLCHAIN_GCC_URL  URL for downloading GCC compiler   [default URL provided]
             TOOLCHAIN_GLIBC_URL  URL for downloading glibc library  [default URL provided]
               TOOLCHAIN_GDB_URL  URL for downloading GDB debugger   [default URL provided]
              TOOLCHAIN_MPFR_URL  URL for downloading MPFR library   [default URL provided]
               TOOLCHAIN_GMP_URL  URL for downloading GMP library    [default URL provided]
               TOOLCHAIN_MPC_URL  URL for downloading MPC library    [default URL provided]
               TOOLCHAIN_ISL_URL  URL for downloading ISL library    [default URL provided]
             TOOLCHAIN_CLOOG_URL  URL for downloading CLOOG library  [default URL provided]

          TOOLCHAIN_DOWNLOAD_DIR  Dowload directory for toolchain's components [default: /tmp]
               TOOLCHAIN_BASEDIR  Base directory for toolchain's components. If provided, script
                                  will extract source files to this directory and keep them (
                                  (in TOOLCHAIN_BASEDIR/component_name directory) for future use
                                  to avoid repetition download. At the next run of the script, if
                                  the same directory is provided, no download (and possibly extraction)
                                  of the source files would be required.

                                  Morover script marks builded packages by placing empty files
                                  (named '.compiled', '.installed', ...) in the build directories
                                  (under $TOOLCHAIN_BASEDIR/build/component_name) of the component.
                                  If component's build is requested again (e.g. in situation when
                                  the whole toolchain is build again after interrupted build), it 
                                  will be skipped (as long as build version of the component matches)
                                  to avoid an overhead.

                                  If TOOLCHAIN_BASEDIR is not set, source files are extracted 
                                  and build in the TOOLCHAIN_DOWNLOAD_DIR and no check is performed
                                  
          TOOLCHAIN_FORCE_REBUID  If set to non-empty valule, COMPONENTS will be rebuil even if
                                  it was marked as already built in TOOLCHAIN_BASEDIR directory
                                  
END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="gcc-toolchain"

# ====================================================== Default configuration ===================================================== #

# Components' version
var_set_default TOOLCHAIN_BINUTILS_VERSION "2.37"
var_set_default TOOLCHAIN_GCC_VERSION      "11.2.0"
var_set_default TOOLCHAIN_GLIBC_VERSION    "2.34"
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

# ============================================================ Functions =========================================================== #



# ============================================================== Main ============================================================== #

main() {

    # Arguments

    # ---------------------------------- Configuration ----------------------------------

    # Options
    local defs=(
        '--help',help,f
    )

    # Dependencies
    local dependencies=(
        
    )

    # ------------------------------------ Processing -----------------------------------

    # Parsed options
    parse_argumants

    # Parse argument

    # Validate argument

    # Install dependencies
    install_packages --su -y -v -U dependencies || {
        logc_error "Could not install required dependencies"
        return 1
    }
    
    # Perform corresponding routine
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

