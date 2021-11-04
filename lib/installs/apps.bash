# ====================================================================================================================================
# @file     packages.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 9:28:52 pm
# @modified Thursday, 4th November 2021 12:02:54 am
# @project  BashUtils
# @brief
#    
#    Functions related to inspecting applications installed in the system
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

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
