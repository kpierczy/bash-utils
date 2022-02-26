#!/usr/bin/env bash
# ====================================================================================================================================
# @file     gdb.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Saturday, 26th February 2022 4:24:08 pm
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
    local -n extra_config="$1"

    # ---------------------------- Prepare predefined flags -----------------------------

    local -a CONFIG_FLAGS=()
    local -a BUILD_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"                                                                 )
    CONFIG_FLAGS+=( "--host=${opts[host]}"                                                                   )
    CONFIG_FLAGS+=( "--target=${opts[target]}"                                                               )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}"                                                               )
    CONFIG_FLAGS+=( "--with-libexpat"                                                                        )
    CONFIG_FLAGS+=( "--with-libexpat-prefix=${dirs[install_host]}/usr"                                       )
    CONFIG_FLAGS+=( "--with-system-gdbinit=${dirs[prefix]}/${opts[host]}/${names[toolchain_id]}/lib/gdbinit" )
    # Add documentation flags
    is_var_set opts[with_doc] && {
        CONFIG_FLAGS+=( "--infodir=${dirs[prefix_doc]}/info" )
        CONFIG_FLAGS+=( "--mandir=${dirs[prefix_doc]}/man"   )
        CONFIG_FLAGS+=( "--htmldir=${dirs[prefix_doc]}/html" )
        CONFIG_FLAGS+=( "--pdfdir=${dirs[prefix_doc]}/pdf"   )
    }
    # Add extra config
    CONFIG_FLAGS+=( ${extra_config[@]} )

    # -------------------------------------- Build --------------------------------------

    # Build the library
    build_component 'gdb' || return 1

    # ------------------------------- Build documentation -------------------------------

    local build_dir=${dirs[build]}/${names[gdb]}

    # If documentation is requrested
    if is_var_set opts[with_doc]; then
        # If documentation has not been already built (or if rebuilding is forced)
        if ! is_directory_marked $build_dir 'install' 'doc' || is_var_set opts[force]; then

            log_info "Installing GDB documentation..."

            # Enter build directory
            pushd $build_dir > /dev/null

            # Remove target marker
            remove_directory_marker $build_dir 'install' 'doc'
            # Build documentation
            if is_var_set opts[verbose_tools]; then
                make install-html install-pdf
            else
                make install-html install-pdf > /dev/null
            fi
            # Mark build directory with the coresponding marker
            mark_directory $build_dir 'install' 'doc'        

            # Back to the previous location
            popd > /dev/null

            log_info "GDB documentation installed"

        # Otherwise, skip building
        else
            log_info "Skipping ${names[gdb]} documentation installation"
        fi
    fi

}

# ========================================================= Implementation ========================================================= #

# ---------------------------------------------------------------------------------------
# @brief Builds GDB debugger and installs into the <prefix> directory. `gdbinit` system
#   files are written into the <prefix>/<host>/<toolchain_id>/lib/gdbinit directory.
#   GDB is built twice - with and without support for Python GDB
# ---------------------------------------------------------------------------------------
function build_gdb() {

    local -a gdb_extra_config=(
        "--with-python=no"
    )

    # First we build GDB without python support
    build_gdb_impl gdb_extra_config

    local -a gdb_extra_config=(
        "--with-python=yes"
        "--program-prefix=${names[toolchain_id]}-"
        "--program-suffix=-py"
    )

    # Then build gdb with python support
    build_gdb_impl gdb_extra_config

}
