#!/usr/bin/env bash
# ====================================================================================================================================
# @file     download_and_extract.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Friday, 5th November 2021 4:13:38 pm
# @modified Friday, 5th November 2021 5:38:15 pm
# @project  BashUtils
# @brief
#    
#    Test of the download_and_extract() function from `files` library
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
describe download_and_extract

    it "download and extract"

        declare URL='https://github.com/Kitware/CMake/releases/download/v3.22.0-rc2/cmake-3.22.0-rc2.tar.gz'
        declare DDIR='/tmp'
        declare EDIR='/tmp'
        declare LOG_CONTEXT='context'
        declare LOG_TARGET='CMake'

        # Download some file
        download_and_extract -v "$URL" "$DDIR" "$EDIR"
        assert equal 0 $?
        # Check if file was downloaded properly
        [[ -f $DDIR/$(basename $URL) ]]
        assert equal 0 $?
        # Check if file was downloaded properly
        declare ARCHIEVE_NAME=$(basename $URL)
        declare ARCHIEVE_PATH=$EDIR/${ARCHIEVE_NAME%.tar.gz}
        [[ -d "$ARCHIEVE_PATH" ]]
        assert equal 0 $?

    ti

end_describe
