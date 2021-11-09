#!/usr/bin/env bash
# ====================================================================================================================================
# @file     archieves.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 8:39:00 pm
# @modified Tuesday, 9th November 2021 3:26:56 am
# @project  BashUtils
# @brief
#    
#    Test suite from functions from lib/files/archieves.bash module
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

# Test get_archieve_extension function
describe get_archieve_extension

    it "Check invalid archieve"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "invalid_archieve_filename")"
        assert equal $? 1
        assert equal "$archieve_ext" ""
    ti

    it "Check uncompressed tarball archieve"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "tarball_archieve.tar")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar"
    ti

    it "Check compressed tarball archieve (.tgz)"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "compressed_tarball_archieve.tgz")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar.gz"
    ti

    it "Check compressed tarball archieve (.tbz)"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "compressed_tarball_archieve.tbz")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar.bz2"
    ti

    it "Check compressed tarball archieve (.txz)"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "compressed_tarball_archieve.txz")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar.xz"
    ti

    it "Check zip archieve"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "zip_archieve.zip")"
        assert equal $? 0
        assert equal "$archieve_ext" "zip"
    ti

    it "Check 7z archieve"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "7z_archieve.7z")"
        assert equal $? 0
        assert equal "$archieve_ext" "7z"
    ti

    it "Check compressed tarball archieve (.tar.gz)"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "compressed_tarball_archieve.tar.gz")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar.gz"
    ti

    it "Check compressed tarball archieve (.tar.bz2)"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "compressed_tarball_archieve.tar.bz2")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar.bz2"
    ti

    it "Check compressed tarball archieve (.tar.xz)"
        local archieve_ext=""
        archieve_ext="$(get_archieve_extension "compressed_tarball_archieve.tar.xz")"
        assert equal $? 0
        assert equal "$archieve_ext" "tar.xz"
    ti

end_describe

