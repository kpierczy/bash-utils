#!/usr/bin/env bash
# ====================================================================================================================================
# @file     gdb.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 4:35:44 am
# @project  bash-utils
# @brief
#    
#    Installation routines for gdb tool
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================= Helpers ============================================================ #

function build_gdb_impl() {

    # Arguments
    local extra_config="$1"

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a COMPILE_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"                                                         )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                                                           )
    CONFIG_FLAGS+=( "--target=${opts[target]}"                                                       )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}"                                                       )
    CONFIG_FLAGS+=( "--with-libexpat-prefix=${opts[basedir]}/install/host/usr"                       )
    CONFIG_FLAGS+=( "--with-system-gdbinit=${opts[install_host]}/${names[toolchain_id]}/lib/gdbinit" )
    # Add documentation flags
    is_var_set opts[with_doc] && {
        CONFIG_FLAGS+=( "--infodir=${dirs[prefix_doc]}/info" )
        CONFIG_FLAGS+=( "--mandir=${dirs[prefix_doc]}/man"   )
        CONFIG_FLAGS+=( "--htmldir=${dirs[prefix_doc]}/html" )
        CONFIG_FLAGS+=( "--pdfdir=${dirs[prefix_doc]}/pdf"   )
    }

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'gdb'

    # ------------------------------- Build documentation -------------------------------

    is_var_set opts[with_doc] && {

        log_info "Installing GDB documentation..."

        # Enter build directory
        pushd ${dirs[build]}/${names[gdb]}

        # Build documentation
        make install-html install-pdf
        

        # Back to the previous location
        popd

        log_info "GDB documentation installed"

    }

}

# ========================================================= Implementation ========================================================= #

function build_gdb() {

    # First we build GDB without python support
    build_gdb_impl "--with-python=no"

    # Then build gdb with python support
    build_gdb_impl "--with-python=yes --program-prefix=${names[toolchain_id]}-  --program-suffix=-py"

}
