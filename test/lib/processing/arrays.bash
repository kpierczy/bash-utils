#!/usr/bin/env bash
# ====================================================================================================================================
# @file     arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:42:12 pm
# @modified Tuesday, 9th November 2021 2:45:15 pm
# @project  BashUtils
# @brief
#    
#    Test suite for arrays-related tools
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

# Test is_array_element function
describe is_array_element

    it "Check if an array contains an element"

        local -a array=("a" "1" "m" "k9")
        is_array_element array "a"
        assert equal $? 0
        
    ti

    it "Check if an array doesn't contains an element"

        local -a array=("a" "1" "m" "k9")
        is_array_element array "b"
        assert equal $? 1
        
    ti

end_describe
