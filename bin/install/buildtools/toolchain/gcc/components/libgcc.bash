#!/usr/bin/env bash
# ====================================================================================================================================
# @file     libgcc.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 4:44:35 am
# @project  bash-utils
# @brief
#    
#    Installation routines for libgcc tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function build_libgcc() {

    # ------------------------------- Prepare environment -------------------------------

    # Replace <prefix>/<toolchain-id>/usr with symbolic link to <basedir>/src [?]
    rm -f "${dirs[prefix]}/${names[toolchain_id]}/usr"
    ln -s "${dirs[src]}" "${dirs[prefix]}/${names[toolchain_id]}/usr"

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
    CONFIG_FLAGS+=( "--with-sysroot=${dirs[prefix]}/${dirs[target]}"                          )
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

    # ------------------------------------- Cleanup -------------------------------------
    
    # Remove unused binaries
    remove ${dirs[prefix]}/bin/arm-none-eabi-gccbug
    # Remove unused libiberty binaries
    rm -rf ${dirs[prefix]}/lib/libiberty.a
    for lib in $(find ${dirs[prefix]}/${names[toolchain_id]}/lib -name libiberty.a); do
        rm -rf $lib
    done
    # Remove unused include directory
    rm -rf ${dirs[prefix]}/include
    # Remove unused 'usr' directory
    rm -rf ${dirs[prefix]}/arm-none-eabi/usr

}
