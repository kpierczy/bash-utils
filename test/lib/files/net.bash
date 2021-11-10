#!/usr/bin/env bash
# ====================================================================================================================================
# @file     net.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 1:58:33 am
# @modified Wednesday, 10th November 2021 5:07:52 am
# @project  BashUtils
# @brief
#    
#    Test suite for functions from lib/files/net.bash module
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

# Test wget_and_localize function
describe wget_and_localize

    alias setup='cd /tmp'

    # URL to be downloaded
    declare url="https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz"
    # Archieve default name
    declare arch_dflt_name=$(basename $url)
    # Name of the extracted folder
    declare arch_extracted_name=${arch_dflt_name%.tgz}
    
    it "Simple download with default output name"

        # Wget and localize
        local path=$(wget_and_localize $url); assert equal $? "0"
        
        # Assert file was downloaded
        [[ -f "$arch_dflt_name" ]]; assert equal $? "0"
        # Assert a valid pathw as returned
        assert equal "$path" "$arch_dflt_name"

        # Remove downloaded file
        rm -rf "$arch_dflt_name"
 
    ti
    
    it "Simple download with non-default output name"

        local target="archieve.tgz"

        # Wget and localize
        local path=$(wget_and_localize     \
            --output-document=${target}    \
        $url); assert equal $? "0"

        # Assert file was downloaded
        [[ -f "$target" ]]; assert equal $? "0"
        # # Assert a valid pathw as returned
        assert equal "$path" "$target"

        # Remove downloaded file
        rm -rf "$target"
 
    ti

end_describe