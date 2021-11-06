#!/usr/bin/env bash
# ====================================================================================================================================
# @file     get_archieve_ext.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 2:40:57 pm
# @modified Saturday, 6th November 2021 2:44:44 pm
# @project  BashUtils
# @brief
#    
#    Test suit for get_archieve_ext() library function
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source testing helpers
source $BASH_UTILS_HOME/lib/test/shpec_support.bash

# Enable macros' expansion
shopt -s expand_aliases

# =========================================================== Test cases =========================================================== #

# Source library
source $BASH_UTILS_HOME/source_me.bash

# Test function
describe get_archieve_ext

    it "Check .tar files"
        assert equal $(get_archieve_ext "a.tar") "tar"
    ti
    
    it "Check .tar.gz files"
        assert equal $(get_archieve_ext "a.tar.gz") "tar.gz"
    ti
    
    it "Check .tar.bz2 files"
        assert equal $(get_archieve_ext "a.tar.bz2") "tar.bz2"
    ti
    
    it "Check .zip files"
        assert equal $(get_archieve_ext "a.zip") "zip"
    ti
    
    it "Check .7z files"
        assert equal $(get_archieve_ext "a.7z") "7z"
    ti
    

end_describe