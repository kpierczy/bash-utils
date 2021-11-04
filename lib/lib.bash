#!/usr/bin/env bash
# ====================================================================================================================================
# @file     lib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:45:51 am
# @modified Thursday, 4th November 2021 12:48:50 am
# @project  BashUtils
# @brief
#    
#    File consolidating `source` calls to all scripts defined in the library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Get script's home directory
SCRIPT_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# Source components
source $SCRIPT_HOME/installs/apps.bash
source $SCRIPT_HOME/installs/packages.bash
source $SCRIPT_HOME/installs/python.bash
source $SCRIPT_HOME/shell/git.bash
source $SCRIPT_HOME/shell/ros.bash
source $SCRIPT_HOME/shell/docker.bash
source $SCRIPT_HOME/logging/logging.bash
source $SCRIPT_HOME/files/files.bash
source $SCRIPT_HOME/processing/functional.bash
source $SCRIPT_HOME/scripting/self_inspection.bash
source $SCRIPT_HOME/scripting/settings.bash
source $SCRIPT_HOME/scripting/variables.bash
source $SCRIPT_HOME/scripting/general.bash
source $SCRIPT_HOME/scripting/strict_mode.bash
source $SCRIPT_HOME/test/shpec_support.bash
source $SCRIPT_HOME/debug/tracing.bash
