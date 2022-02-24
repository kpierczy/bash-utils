#!/usr/bin/env bash
# ====================================================================================================================================
# @file     libcpp.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 4:26:19 am
# @project  bash-utils
# @brief
#    
#    Installation routines for libcpp tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================


# ========================================================= Implementation ========================================================= #

function build_libcpp() {

    # ------------------------------- Prepare environment -------------------------------

    # Replace <prefix>/<toolchain-id>/usr with symbolic link to <basedir>/src [?]
    rm -f "${dirs[install_target]}/target-libs/arm-none-eabi/usr"
    ln -s "${dirs[src]}" "${dirs[install_target]}/target-libs/arm-none-eabi/usr"

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

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
    CONFIG_FLAGS+=( "--with-sysroot=${dirs[install_host]}/${names[toolchain_id]}"             )
    CONFIG_FLAGS+=( "--with-python-dir=share/${names[toolchain_base]}-${names[toolchain_id]}" )
    # Add documentation flags
    is_var_set opts[with_doc] && {
        CONFIG_FLAGS+=( "--infodir=${dirs[prefix_doc]}/info" )
        CONFIG_FLAGS+=( "--mandir=${dirs[prefix_doc]}/man"   )
        CONFIG_FLAGS+=( "--htmldir=${dirs[prefix_doc]}/html" )
        CONFIG_FLAGS+=( "--pdfdir=${dirs[prefix_doc]}/pdf"   )
    }

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'gcc'

    # ------------------------------- Build documentation -------------------------------

    is_var_set opts[with_doc] && {

        log_info "Installing libgcc documentation..."

        # Enter build directory
        pushd ${dirs[build]}/${names[gcc]}

        # Build documentation
        make install-html install-pdf
        

        # Back to the previous location
        popd

        log_info "Libgcc documentation installed"

    }

}
