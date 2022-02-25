#!/usr/bin/env bash
# ====================================================================================================================================
# @file     newlib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Friday, 25th February 2022 5:16:47 pm
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
    local -a BUILD_FLAGS=()

    # Prepare config flags
    CONFIG_FLAGS+=( "--build=${opts[build]}"   )
    CONFIG_FLAGS+=( "--host=${opts[host]}"     )
    CONFIG_FLAGS+=( "--target=${opts[target]}" )
    CONFIG_FLAGS+=( "--prefix=${dirs[prefix]}" )
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
    build_component 'libc' 'newlib' 'newlib' || return 1

    # ------------------------------- Build documentation -------------------------------

    local build_dir=${dirs[build]}/newlib-${versions[libc]}

    # If documentation is requrested
    if is_var_set opts[with_doc]; then
        # If documentation has not been already built (or if rebuilding is forced)
        if ! is_directory_marked $build_dir 'install' 'doc' || is_var_set opts[force]; then

            log_info "Installing newlib documentation..."

            # Enter build directory
            pushd $build_dir > /dev/null

            # Remove target marker
            remove_directory_marker $build_dir 'install' 'doc'
            
            # Build PDF documentation
            if is_var_set opts[verbose_tools]; then
                make pdf
            else
                make pdf > /dev/null
            fi
            # Install documentation
            mkdir -p "${dirs[prefix_doc]}/pdf"
            cp "./${names[toolchain_id]}/newlib/libc/libc.pdf" "${dirs[prefix_doc]}/pdf/libc.pdf"
            cp "./${names[toolchain_id]}/newlib/libm/libm.pdf" "${dirs[prefix_doc]}/pdf/libm.pdf"

            # Build HTML documentation
            if is_var_set opts[verbose_tools]; then
                make html
            else
                make html > /dev/null
            fi
            # Install documentation
            mkdir -p "${dirs[prefix_doc]}/html"
            deep_copy_dir "./${names[toolchain_id]}/newlib/libc/libc.html" "${dirs[prefix_doc]}/html/libc"
            deep_copy_dir "./${names[toolchain_id]}/newlib/libm/libm.html" "${dirs[prefix_doc]}/html/libm"

            # Mark build directory with the coresponding marker
            mark_directory $build_dir 'install' 'doc'
                
            # Back to the previous location
            popd > /dev/null

            log_info "Newlib documentation installed"

        # Otherwise, skip building
        else
            log_info "Skipping ${names[libc]} documentation installation"
        fi
    fi

    # ------------------------------------- Cleanup -------------------------------------
    
    # Restore environment
    restore_env_stack
    
}
