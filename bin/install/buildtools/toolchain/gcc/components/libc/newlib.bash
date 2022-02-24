#!/usr/bin/env bash
# ====================================================================================================================================
# @file     newlib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 3:06:14 am
# @project  bash-utils
# @brief
#    
#    Installation routines for newlib tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

function build_newlib() {

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"                         )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                           )
    CONFIG_FLAGS+=( "--target=${opts[target]}"                       )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}"                       )
    # Add documentation flags
    is_var_set opts[with_doc] && {
        CONFIG_FLAGS+=( "--infodir=${dirs[prefix_doc]}/info" )
        CONFIG_FLAGS+=( "--mandir=${dirs[prefix_doc]}/man"   )
        CONFIG_FLAGS+=( "--htmldir=${dirs[prefix_doc]}/html" )
        CONFIG_FLAGS+=( "--pdfdir=${dirs[prefix_doc]}/pdf"   )
    }

    # ------------------------------- Prepare environment -------------------------------

    # Clear helper stack to put envs on
    clear_env_stack
    # Add compiled GCC's binaries to path
    prepend_path_env_stack ${dirs[prefix]}/bin

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'libc'

    # ------------------------------- Build documentation -------------------------------

    is_var_set opts[with_doc] && {

        log_info "Installing newlib documentation..."

        # Enter build directory
        pushd ${dirs[build]}/${names[libc]}

        # Build PDF documentation
        make pdf
        # Install documentation
        mkdir -p "${dirs[prefix_doc]}/pdf"
        cp "./${names[toolchain_id]}/newlib/libc/libc.pdf" "${dirs[prefix_doc]}/pdf/libc.pdf"
        cp "./${names[toolchain_id]}/newlib/libm/libm.pdf" "${dirs[prefix_doc]}/pdf/libm.pdf"

        # Build HTML documentation
        make html
        # Install documentation
        mkdir -p "${dirs[prefix_doc]}/html"
        copy_dir "./${names[toolchain_id]}/newlib/libc/libc.html" "${dirs[prefix_doc]}/html/libc"
        copy_dir "./${names[toolchain_id]}/newlib/libm/libm.html" "${dirs[prefix_doc]}/html/libm"

        # Back to the previous location
        popd

        log_info "Newlib documentation installed"

    }

    # ------------------------------------ Finalize -------------------------------------

    # Copy <prefix> content to target's installation directory for future use
    cp -rf ${dirs[prefix]}/* ${dirs[install_target]}/

    # ------------------------------------- Cleanup -------------------------------------
    
    # Restore environment
    restore_env_stack
    # Remove library folder from prefix directory (useless)
    rm -rf ${dirs[prefix]}/lib
    
}
