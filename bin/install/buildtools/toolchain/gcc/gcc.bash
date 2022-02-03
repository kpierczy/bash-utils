#!/usr/bin/env bash
# ====================================================================================================================================
# @file     install.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:28:20 pm
# @modified Wednesday, 10th November 2021 5:45:34 pm
# @project  bash-utils
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
    parse_script_options

    # Parse argument

    # Validate argument

    # Install dependencies
    install_pkg_list --su -y -v -U dependencies || {
        log_error "Could not install required dependencies"
        return 1
    }
    
    # Perform corresponding routine
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

