#!/usr/bin/env bash
# ====================================================================================================================================
# @file     binutils.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 6:01:06 am
# @project  bash-utils
# @brief
#    
#    Installation routines for binutils tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function build_binutils() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"                                )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                                  )
    CONFIG_FLAGS+=( "--target=${opts[target]}"                              )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}"                              )
    CONFIG_FLAGS+=( "--with-sysroot=${dirs[prefix]}/${names[toolchain_id]}" )
    # Add documentation flags
    is_var_set opts[with_doc] && {
        CONFIG_FLAGS+=( "--infodir=${dirs[prefix_doc]}/info" )
        CONFIG_FLAGS+=( "--mandir=${dirs[prefix_doc]}/man"   )
        CONFIG_FLAGS+=( "--htmldir=${dirs[prefix_doc]}/html" )
        CONFIG_FLAGS+=( "--pdfdir=${dirs[prefix_doc]}/pdf"   )
    }

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'binutils'

    # ------------------------------- Build documentation -------------------------------

    is_var_set opts[with_doc] && {

        log_info "Installing binutils documentation..."

        # Enter build directory
        pushd ${dirs[build]}/${names[binutils]}

        # Build documentation
        make install-html install-pdf

        # Back to the previous location
        popd

        log_info "Binutils documentation installed"

    }

    # ------------------------------------ Finalize -------------------------------------

    # Copy <prefix> content to target's installation directory for future use
    cp -rf ${dirs[prefix]}/* ${dirs[install_target]}/

    # ------------------------------------- Cleanup -------------------------------------
    
    # Remove library folder from prefix directory (useless)
    rm -rf ${dirs[prefix]}/lib

}

