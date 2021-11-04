# ====================================================================================================================================
# @file     sourceMe.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 2nd November 2021 10:18:45 pm
# @modified Thursday, 4th November 2021 12:45:46 am
# @project  Winder
# @brief
#    
#    Main source script of the BashUtils project. Sourcing it will provide a shell with all functions and aliases defined in the
#    project's library as well ass will exted PATH with directories holding helper scripts and programms.
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Set library home path
BASH_UTILS_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# Add `shpec` library to the PATH
PATH+=:$BASH_UTILS_HOME/dep/shpec/bin

# Add ./bin directory PATH
PATH+=:"$BASH_UTILS_HOME/dep/shpec/bin"

# Source library
source $BASH_UTILS_HOME/lib/lib.bash
