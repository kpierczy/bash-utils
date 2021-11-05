#!/usr/bin/env bash
# ====================================================================================================================================
# @file     lib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:45:51 am
# @modified Thursday, 4th November 2021 9:47:19 pm
# @project  BashUtils
# @brief
#    
#    File consolidating `source` calls to all scripts defined in the library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source components
source $BASH_UTILS_HOME/lib/installs/apps.bash
source $BASH_UTILS_HOME/lib/installs/archieves.bash
source $BASH_UTILS_HOME/lib/installs/packages.bash
source $BASH_UTILS_HOME/lib/installs/python.bash
source $BASH_UTILS_HOME/lib/shell/git.bash
source $BASH_UTILS_HOME/lib/shell/ros.bash
source $BASH_UTILS_HOME/lib/shell/docker.bash
source $BASH_UTILS_HOME/lib/logging/logging.bash
source $BASH_UTILS_HOME/lib/files/files.bash
source $BASH_UTILS_HOME/lib/processing/functional.bash
source $BASH_UTILS_HOME/lib/processing/strings.bash
source $BASH_UTILS_HOME/lib/scripting/functions.bash
source $BASH_UTILS_HOME/lib/scripting/self_inspection.bash
source $BASH_UTILS_HOME/lib/scripting/settings.bash
source $BASH_UTILS_HOME/lib/scripting/variables.bash
source $BASH_UTILS_HOME/lib/scripting/general.bash
source $BASH_UTILS_HOME/lib/scripting/strict_mode.bash
source $BASH_UTILS_HOME/lib/test/shpec_support.bash
source $BASH_UTILS_HOME/lib/debug/tracing.bash
