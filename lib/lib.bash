#!/usr/bin/env bash
# ====================================================================================================================================
# @file     lib.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 12:45:51 am
# @modified Tuesday, 9th November 2021 3:27:28 am
# @project  BashUtils
# @brief
#    
#    File consolidating `source` calls to all scripts defined in the library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Debug module
source $BASH_UTILS_HOME/lib/debug/tracing.bash

# Files-relaed tools
source $BASH_UTILS_HOME/lib/files/archieves.bash
source $BASH_UTILS_HOME/lib/files/files.bash

# 
source $BASH_UTILS_HOME/lib/installs/apps.bash
source $BASH_UTILS_HOME/lib/installs/packages.bash
source $BASH_UTILS_HOME/lib/installs/python.bash

# Command line tools
source $BASH_UTILS_HOME/lib/shell/git.bash
source $BASH_UTILS_HOME/lib/shell/ros.bash
source $BASH_UTILS_HOME/lib/shell/docker.bash

# Logging module
source $BASH_UTILS_HOME/lib/logging/logging.bash

# Data processing toolkit
source $BASH_UTILS_HOME/lib/processing/functional.bash
source $BASH_UTILS_HOME/lib/processing/stack.bash
source $BASH_UTILS_HOME/lib/processing/strings.bash

# General scripting tools
source $BASH_UTILS_HOME/lib/scripting/functions.bash
source $BASH_UTILS_HOME/lib/scripting/self_inspection.bash
source $BASH_UTILS_HOME/lib/scripting/settings.bash
source $BASH_UTILS_HOME/lib/scripting/variables.bash
source $BASH_UTILS_HOME/lib/scripting/general.bash
source $BASH_UTILS_HOME/lib/scripting/strict_mode.bash

# Bash unit-test-related utilities
source $BASH_UTILS_HOME/lib/test/shpec_support.bash
