#!/usr/bin/env bash
# ====================================================================================================================================
# @file     finalize.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 5:49:03 pm
# @modified Thursday, 24th February 2022 5:17:49 am
# @project  bash-utils
# @brief
#    
#    Routines finalizing toolchain's build
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Strip binary files as in "strip binary" form
# 
# @param name
#    name of the library (lower case)
# @environment
#
#   CONFIG_FLAGS  array containing configuration options for the build
#   COMPILE_FLAGS array containing compilation options for the build
# ---------------------------------------------------------------------------------------
function strip_binary() {
    
    # Arguments
    local bin="$1"

    # Check type of the given file
    file $bin | grep -q -e "\bELF\b" -e "\bPE\b" -e "\bPE32\b" -e "\bMach-O\b"
    # If one of the supported types given, strip
    if [ $? -eq 0 ]; then
        strip $bin 2>/dev/null || true
    fi

}

# ========================================================= Implementation ========================================================= #

function build_finalize() {

    # ------------------------------------- Cleanup -------------------------------------

    # Pretidy build by removing unused files
    rm -rf "${dirs[prefix]}/lib/libiberty.a"
    find "${dirs[prefix]}" -name '*.la' -exec rm '{}' ';'

    # --------------------------------- Strip binaries ----------------------------------

    # Strip host obejct in release builds
    is_var_set opts[debug] || {

        # Strip tolchain's binaries in 'bin' subfolder
        for bin in $(find ${dirs[prefix]}/bin/ -name ${names[toolchain_id]}-\*); do
            strip_binary $bin
        done
        # Strip tolchain's binaries in '<toolchain-id>/bin' subfolder
        for bin in $(find ${dirs[prefix]}/${names[toolchain_id]}/bin/ -maxdepth 1 -mindepth 1 -name \*); do
            strip_binary $bin
        done
        # Strip tolchain's binaries in 'lib/gcc/<toolchain-id>/<version>' subfolder
        for bin in $(find ${dirs[prefix]}/lib/gcc/${names[toolchain_id]}/${versions[gcc]}/ -maxdepth 1 -name \* -perm /111 -and ! -type d); do
            strip_binary $bin
        done

    }

    # Strip target obejct in release builds
    is_var_set opts[debug] || {

        # Clear helper stack to put envs on
        clear_env_stack
        # Add compiled GCC's binaries to path
        prepend_path_env_stack ${dirs[prefix]}/bin
        
        local target_lib

        # Symbols to strip
        local sym_to_strip
        sym_to_strip+=" -R .comment"
        sym_to_strip+=" -R .note"
        sym_to_strip+=" -R .debug_info"
        sym_to_strip+=" -R .debug_aranges"
        sym_to_strip+=" -R .debug_pubnames"
        sym_to_strip+=" -R .debug_pubtypes"
        sym_to_strip+=" -R .debug_abbrev"
        sym_to_strip+=" -R .debug_line"
        sym_to_strip+=" -R .debug_str"
        sym_to_strip+=" -R .debug_ranges"
        sym_to_strip+=" -R .debug_loc"

        # Strip static libraries
        for target_lib in $(find ${dirs[prefix]}/${names[toolchain_id]}/lib -name \*.a); do
            ${names[toolchain_id]}-objcopy \
                $sym_to_strip              \
                $target_lib                \
            || true
        done

        # Strip objects
        for target_obj in $(find ${dirs[prefix]}/${names[toolchain_id]}/lib -name \*.o); do
            ${names[toolchain_id]}-objcopy \
                $sym_to_strip              \
                $target_lib                \
            || true
        done

        # Strip libgcc static libraries
        for target_lib in $(find ${dirs[prefix]}/${names[toolchain_id]}-none-eabi/$GCC_VER -name \*.a); do
            ${names[toolchain_id]}-objcopy \
                $sym_to_strip              \
                $target_lib                \
            || true
        done

        # Strip libgcc objects
        for target_obj in $(find ${dirs[prefix]}/${names[toolchain_id]}-none-eabi/$GCC_VER -name \*.o); do
            ${names[toolchain_id]}-objcopy \
                $sym_to_strip              \
                $target_lib                \
            || true
        done

        # Restore environment
        restore_env_stack
    
    }

    # --------------------------------- Create package ----------------------------------

    # Create package archieve, if requested
    is_var_set opts[with_package] || {

        # Remove package if already exists
        rm -f ${opts[with_package]}

        # Enter build directory
        pushd ${dirs[build]}
        # Create symbolic link to installation dir
        mkdir -p ${dirs[package]}
        ln -s ${dirs[prefix]} ${dirs[package]}/$(basename ${dirs[prefix]})
        
        # Make the package tarball
        tar cjf ${dirs[package]}/${opts[with_package]}                   \
            --exclude="host-${opts[host]}"                               \
            "${dirs[package]}/$(basename ${dirs[prefix]})/arm-none-eabi" \
            "${dirs[package]}/$(basename ${dirs[prefix]})/bin"           \
            "${dirs[package]}/$(basename ${dirs[prefix]})/lib"           \
            "${dirs[package]}/$(basename ${dirs[prefix]})/share"

    }
}
