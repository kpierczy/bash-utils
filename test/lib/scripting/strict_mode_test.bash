#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strict_mode_test.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 1:58:55 am
# @modified Thursday, 4th November 2021 4:35:19 pm
# @project  Winder
# @brief
#    
#    Unit tests of the 'strict_mode' module of te library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source testing helpers
source $BASH_UTILS_HOME/lib/test/shpec_support.bash

# Enable macros' expansion
shopt -s expand_aliases

# =========================================================== Test cases =========================================================== #

# Source tested module
source $BASH_UTILS_HOME/lib/scripting/strict_mode.bash
# Disable treating unset variable as error
set -o nounset

# Test strict_mode() function
describe strict_mode

    it "sets errexit"
        strict_mode on
        [[ $- == *e* ]]
        ret=$?
        strict_mode off
        assert equal 0 $ret
    ti

    it "unsets errexit"
        set -o errexit
        strict_mode off
        [[ $- == *e* ]]
        assert unequal 0 $?
    ti

    it "sets nounset"
        set +o nounset
        strict_mode on
        set +o errexit
        [[ $- == *u* ]]
        ret=$?
        strict_mode off
        assert equal 0 $ret
    ti

    it "sets pipefail"
        strict_mode on
        set +o errexit
        [[ :$SHELLOPTS: == *:pipefail:* ]]
        ret=$?
        strict_mode off
        assert equal 0 $ret
    ti
    
end_describe
