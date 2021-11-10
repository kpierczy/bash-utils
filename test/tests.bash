#!/usr/bin/env bash
# ====================================================================================================================================
# @file     tests.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 3:24:06 am
# @modified Wednesday, 10th November 2021 6:52:48 pm
# @project  BashUtils
# @brief
#    
#    Composition of all bash tests. To run the testsuite, source `source_me.bash` file and run `shpec` with the name of the testfile
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================= Library ============================================================ #

# Files module
source $BASH_UTILS_HOME/test/lib/files/archieves.bash
source $BASH_UTILS_HOME/test/lib/files/files.bash
source $BASH_UTILS_HOME/test/lib/files/net.bash

# Processing module
source $BASH_UTILS_HOME/test/lib/processing/arrays.bash
source $BASH_UTILS_HOME/test/lib/processing/stack.bash
source $BASH_UTILS_HOME/test/lib/processing/strings.bash

# Programs-related modules
source $BASH_UTILS_HOME/test/lib/programs/apps.bash
