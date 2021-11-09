#!/usr/bin/env bash
# ====================================================================================================================================
# @file     stack.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 11:13:15 pm
# @modified Tuesday, 9th November 2021 1:02:05 am
# @project  BashUtils
# @brief
#    
#    Test suite for bash implementation of the stack
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

# Test get_archieve_ext function
describe stack

    it "Check pushing & printing (default stack)"

        # Push some elements
        push_stack elem1; assert equal $? 0
        push_stack elem2; assert equal $? 0
        push_stack elem3; assert equal $? 0
        push_stack elem4; assert equal $? 0

        # Print elements
        result=$(print_stack); assert equal $? 0
        # Test result
        assert equal "$result" "elem1\nelem2\nelem3\nelem4"
        
    ti
    
    it "Check pushing & popping (default stack)"
        
        local ret

        # Push some elements
        push_stack elem1; assert equal $? 0
        push_stack elem2; assert equal $? 0
        push_stack elem3; assert equal $? 0
        push_stack elem4; assert equal $? 0

        # Pop some elements
        pop_stack ret; assert equal $? 0; assert equal "$ret" "elem4"
        pop_stack ret; assert equal $? 0; assert equal "$ret" "elem3"

        # Print elements
        result=$(print_stack); assert equal $? 0
        # Test result
        assert equal "$result" "elem1\nelem2"
        
    ti

    it "Check pushing & printing (custom stack)"

        # Push some elements
        push_stack st elem1; assert equal $? 0
        push_stack st elem2; assert equal $? 0
        push_stack st elem3; assert equal $? 0
        push_stack st elem4; assert equal $? 0

        # Print elements
        result=$(print_stack st); assert equal $? 0
        # Test result
        assert equal "$result" "elem1\nelem2\nelem3\nelem4"
        
    ti
    
    it "Check pushing & popping (custom stack)"
        
        local ret

        # Push some elements
        push_stack st elem1; assert equal $? 0
        push_stack st elem2; assert equal $? 0
        push_stack st elem3; assert equal $? 0
        push_stack st elem4; assert equal $? 0
        push_stack st elem5; assert equal $? 0
        push_stack st elem6; assert equal $? 0

        # Pop some elements
        pop_stack st ret; assert equal $? 0; assert equal "$ret" "elem6"
        pop_stack st ret; assert equal $? 0; assert equal "$ret" "elem5"
        pop_stack st ret; assert equal $? 0; assert equal "$ret" "elem4"
        pop_stack st ret; assert equal $? 0; assert equal "$ret" "elem3"

        # Print elements
        result=$(print_stack st); assert equal $? 0
        # Test result
        assert equal "$result" "elem1\nelem2"
        
    ti
    
    it "Check stack's size"

        push_stack st elem1; assert equal $? 0
        push_stack st elem2; assert equal $? 0
        push_stack st elem3; assert equal $? 0
        assert equal "$(get_stack_size st)" "3"

        push_stack st elem1; assert equal $? 0
        push_stack st elem2; assert equal $? 0
        push_stack st elem3; assert equal $? 0
        assert equal "$(get_stack_size st)" "6"

        local ret
        
        pop_stack st ret; assert equal $? 0
        pop_stack st ret; assert equal $? 0
        assert equal "$(get_stack_size st)" "4"

    ti

end_describe
