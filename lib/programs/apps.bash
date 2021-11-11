# ====================================================================================================================================
# @file     packages.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 9:28:52 pm
# @modified Thursday, 11th November 2021 1:01:59 am
# @project  BashUtils
# @brief
#    
#    Functions related to inspecting applications installed in the system
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Check whether the @p app is installed in the system by
#    calling `which` on it
#
# @param app 
#    name of the app
#
# @returns 
#     @c 0 if app is runnable from the calling context \n
#     @c 1 otherwise
# -------------------------------------------------------------------
is_app_installed() {

    # Arguments
    local app_="$1"

    # Check if installed
    which "$app_" > /dev/null
}
