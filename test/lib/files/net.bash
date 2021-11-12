#!/usr/bin/env bash
# ====================================================================================================================================
# @file     net.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 1:58:33 am
# @modified Thursday, 11th November 2021 4:15:26 pm
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
    
    it "Simple download with default output name"

        # Remove any archieve that was previously downloaded, if any
        rm -rf "$arch_dflt_name"*
        
        # Wget and localize
        local path=$(wget_and_localize $url); assert equal $? "0"
        echo $path
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
    
    it "Simple download of already downloaded file"

        local path

        # Remove any archieve that was previously downloaded, if any
        rm -rf $arch_dflt_name*

        # Wget and localize
        path=$(wget_and_localize $url); assert equal $? "0"
        path=$(wget_and_localize $url); assert equal $? "0"

        # Assert file was downloaded
        [[ -f "$arch_dflt_name" ]]; assert equal $? "0"
        # # Assert a valid pathw as returned
        assert equal "$path" "${arch_dflt_name}.1"

        # Remove downloaded file
        rm -rf "${arch_dflt_name}"
        rm -rf "${arch_dflt_name}.1"
 
    ti
    
    it "Simple download of already downloaded file with specified destination"

        local target="archieve.tgz"
        local path 

        # Wget and localize
        path=$(wget_and_localize --output-document=${target} $url); assert equal $? "0"
        path=$(wget_and_localize --output-document=${target} $url); assert equal $? "0"

        # Assert file was downloaded
        [[ -f "$target" ]]; assert equal $? "0"
        # # Assert a valid pathw as returned
        assert equal "$path" "$target"

        # Remove downloaded file
        rm -rf "$target"
 
    ti
    
    it "Simple download of already downloaded file with no redownload"

        local path

        # Remove any archieve that was previously downloaded, if any
        rm -rf $arch_dflt_name*

        # Wget and localize
        path=$(wget_and_localize --no-clobber $url); assert equal $? "0"
        path=$(wget_and_localize --no-clobber $url); assert equal $? "2"

        # Assert file was downloaded
        [[ -f "$arch_dflt_name" ]]; assert equal $? "0"
        # # Assert a valid pathw as returned
        assert equal "$path" "${arch_dflt_name}"

        # Remove downloaded file
        rm -rf "$arch_dflt_name"
 
    ti
    
    it "Simple download of already downloaded file with specified destination and no redownload"

        local target="archieve.tgz"
        local path 

        # Wget and localize
        path=$(wget_and_localize --no-clobber --output-document=${target} $url); assert equal $? "0"
        path=$(wget_and_localize --no-clobber --output-document=${target} $url); assert equal $? "2"

        # Assert file was downloaded
        [[ -f "$target" ]]; assert equal $? "0"
        # # Assert a valid pathw as returned
        assert equal "$path" "$target"

        # Remove downloaded file
        rm -rf "$target"
 
    ti

end_describe