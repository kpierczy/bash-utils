#!/usr/bin/env bash
# ====================================================================================================================================
# @file     gcc.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Friday, 25th February 2022 9:51:04 am
# @project  bash-utils
# @brief
#    
#    Installation routines for gcc tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function build_gcc() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a BUILD_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"                                                  )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                                                    )
    CONFIG_FLAGS+=( "--target=${opts[target]}"                                                )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}"                                                )
    CONFIG_FLAGS+=( "--libexecdir=${dirs[prefix]}/lib"                                        )
    CONFIG_FLAGS+=( "--with-gmp=${dirs[install_host]}/usr"                                    )
    CONFIG_FLAGS+=( "--with-mpfr=${dirs[install_host]}/usr"                                   )
    CONFIG_FLAGS+=( "--with-mpc=${dirs[install_host]}/usr"                                    )
    CONFIG_FLAGS+=( "--with-isl=${dirs[install_host]}/usr"                                    )
    CONFIG_FLAGS+=( "--with-libelf=${dirs[install_host]}/usr"                                 )
    CONFIG_FLAGS+=( "--with-sysroot=${dirs[prefix]}/${names[toolchain_id]}"                   )
    CONFIG_FLAGS+=( "--with-python-dir=share/${names[toolchain_base]}-${names[toolchain_id]}" )
    # Add documentation flags
    is_var_set opts[with_doc] && {
        CONFIG_FLAGS+=( "--infodir=${dirs[prefix_doc]}/info" )
        CONFIG_FLAGS+=( "--mandir=${dirs[prefix_doc]}/man"   )
        CONFIG_FLAGS+=( "--htmldir=${dirs[prefix_doc]}/html" )
        CONFIG_FLAGS+=( "--pdfdir=${dirs[prefix_doc]}/pdf"   )
    }

    # Change build target
    local BUILD_TOOL="make all-gcc"
    # Change install target
    local INSTALL_TOOL="make install-gcc"

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'gcc' 'gcc-base' || return 1

    # ------------------------------------- Cleanup -------------------------------------
    
    # Remove useless parts of the compilation result
    rm -rf ${dirs[prefix]}/bin/${names[toolchain_id]}-gccbug
    rm -rf ${dirs[prefix]}/lib/libiberty.a
    rm -rf ${dirs[prefix]}/include

}
