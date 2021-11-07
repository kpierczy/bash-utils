# ====================================================================================================================================
# @file     packages.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 9:28:52 pm
# @modified Sunday, 7th November 2021 7:24:02 pm
# @project  BashUtils
# @brief
#    
#    Functions related to inspecting applications installed in the system
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @param app 
#    name of the app
# @returns 
#     @c 0 if app is runnable from the calling context \n
#     @c 1 otherwise
# -------------------------------------------------------------------
is_app_installed() {

    # Arguments
    local app=$1

    # Check if installed
    which $1 > /dev/null
}


# ============================================================= Aliases ============================================================ #


# -------------------------------------------------------------------
# @brief Common idiom for configuring, uilding and installing
#    software packages from source.
#
# @environment
#
#      SOURCE_PATH  path to the sources' root directory
#       LOG_TARGET  name of the build target in log strings
#     CONFIG_FLAGS  flags passed to the ./configure script (optional)
# -------------------------------------------------------------------
alias make_install_extracted_archieve='
logc_info "Configuring $LOG_TARGET ..."
pushd $SRC_PATH

# Configure target (@note expansion of CONFIG_FLAGS requires word splitting enabled)
local IFS_old=$IFS
enable_word_splitting
./configure ${CONFIG_FLAGS:-}
local ret=$?
IFS=$IFS_old
if [[ $ret != 0 ]] ; then
    popd
    logc_error "Failed to configure $LOG_TARGET"
    return 1
fi

# Build target
if ! make; then
    popd
    logc_error "Failed to build $LOG_TARGET"
    return 1
fi

logc_info "$LOG_TARGET built"

# Install target
if ! make install; then
    popd
    logc_error "Failed to install $LOG_TARGET"
    return 1
fi

popd
logc_info "$LOG_TARGET installed"
'
