#!/usr/bin/env bash
# ====================================================================================================================================
# @file     apps.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 5:31:35 pm
# @modified Wednesday, 10th November 2021 5:34:21 pm
# @project  BashUtils
# @brief
#    
#    Test suite for apps-maniuplation tools
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source testing helpers
source $BASH_UTILS_HOME/lib/test/shpec_support.bash

# Enable macros' expansion
shopt -s expand_aliases

# Source library
source $BASH_UTILS_HOME/source_me.bash

# =========================================================== Test cases =========================================================== #

# Test is_app_installed function
describe is_app_installed

    it "Check if app is installed"

        is_app_installed which
        assert equal $? 0
        
    ti

    it "Check if app is not installed"

        is_app_installed app_that_is_surely_not_installed
        assert equal $? 1

    ti

end_describe

