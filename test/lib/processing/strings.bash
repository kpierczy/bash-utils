#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strings.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 5:16:31 pm
# @modified Wednesday, 10th November 2021 5:25:16 pm
# @project  BashUtils
# @brief
#    
#    Test suite for string-maniuplation tools
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

# Test starts_with function
describe starts_with

    it "Check if string starts with"

        local string="String starting with 'String starting'"
        starts_with "$string" "String starting"
        assert equal $? 0
        
    ti

    it "Check if string does not start with"

        local string="String not starting with 'The Brothers Karamazov'"
        starts_with "$string" "The Brothers Karamazov"
        assert equal $? 1
        
    ti

end_describe

# Test ends_with function
describe ends_with

    it "Check if string ends with"

        local string="String ending with 'and something' and something"
        ends_with "$string" "and something"
        assert equal $? 0
        
    ti

    it "Check if string does not end with"

        local string="String not ending with 'Poor Knight' and something"
        ends_with "$string" "Poor Knight"
        assert equal $? 1
        
    ti

end_describe

# Test is_substring function
describe is_substring

    it "Check if is a substring"

        local string="String containing 'Anna Karenina' between Anna Karenina and Tolstoy"
        is_substring "$string" "Anna Karenina"
        assert equal $? 0
        
    ti

    it "Check if is not a substring"

        local string="String reminding name of the Levin's former nurse"
        is_substring "$string" "Agafya Mikhailovna"
        assert equal $? 1
        
    ti

end_describe
