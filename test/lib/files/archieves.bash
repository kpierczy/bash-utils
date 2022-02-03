#!/usr/bin/env bash
# ====================================================================================================================================
# @file     archieves.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 8th November 2021 8:39:00 pm
# @modified Friday, 12th November 2021 2:00:06 am
# @project  bash-utils
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

# Test is_compatibile_archieve_format function
describe is_compatibile_archieve_format

    it "Check if 'x' is NOT a valid archieve format"
        is_compatibile_archieve_format "x"
        assert equal $? 1
    ti

    it "Check if all valid formats are valid"
        for format in "${BASH_UTILS_SUPPORTED_ARCHIEVES[@]}"; do
            is_compatibile_archieve_format "$format"
            assert equal $? 0
        done
    ti

end_describe

# Test get_archieve_format function
describe get_archieve_format

    it "Check if no-extension file is NOT a valid archieve"
        archieve_format="$(get_archieve_format "invalid_archieve_filename")"
        assert equal $? 1
        assert equal "$archieve_ext" ""
    ti

    it "Check if txt-extension file is NOT a valid archieve"
        archieve_format="$(get_archieve_format "invalid_archieve_filename.txt")"
        assert equal $? 1
        assert equal "$archieve_format" ""
    ti

    it "Check all supported archieve formats are supported"
        
        # List of formats that should be supported
        declare -a supported_formats=(
            "tar.gz"
            "tar.bz2"
            "tar.xz"
            "tar"
            "zip"
        )

        # Testfile
        local testfile="/tmp/file"

        # Create testfil
        touch $testfile

        # Iterate over dictionary of supported archieves' formats
        for format in "${supported_formats[@]}"; do

            # Create an archieve
            create_archieve $format $testfile.$format $testfile

            # Check if format is valid
            archieve_format="$(get_archieve_format "$testfile.$format")"
            assert equal $? 0
            assert equal "$archieve_format" "$format"

            # Remoe archieve
            rm $testfile.$format

        done

        # Remove testfile
        rm $testfile
        
    ti

end_describe

# Test extract_archieve function
describe extract_archieve

    it "Check if invalid option is parsed as error"
        
        extract_archieve -k "arch.tar" 2> /dev/null
        assert equal $? 1

    ti

    it "Check if invalid archieve extension is parsed as error"
        
        extract_archieve "arch.txt" 2> /dev/null
        assert equal $? 1

    ti

    # Name of the testfile
    declare file="test"
    # Basename of the archieve
    declare arch_base_name="arch"
    # Test content of the archieved file
    declare teststring="Hello"  

    it "Check if supported archieves are succesfully extracted"
            
        # Jump to the folder of temporary files
        cd /tmp

        # Enable word splitting to parse extensions from the space-separated etxension's list
        enable_word_splitting
        
        # Iterate over valid archieve format
        for format in "${BASH_UTILS_SUPPORTED_ARCHIEVES[@]}"; do
            
            # Create temporary file
            echo $teststring > $file
            
            # Deduce name of the target archieve
            local archname="$arch_base_name.$extension"
            rm -f $archname

            # Create an archieve
            create_archieve $format $archname $file
            # Remove source file
            rm -f $file
            
            # Extract an archieve
            extract_archieve $archname

            # Test result
            local ret=$?
            assert equal $ret 0
            [[ $ret == 0 ]] || {
                rm -f $archname;
                continue
            }
            
            # Test content of the extracted file
            assert equal "$(cat "$file")" "$teststring"

            # Remove temporary files
            rm -f $archname
            rm -f $file

        done

    ti

    it "Check if supported archieves are succesfully extracted in different directory"

        # Destination directory
        local distdir=dst
            
        # Jump to the folder of temporary files
        cd /tmp

        # Enable word splitting to parse extensions from the space-separated etxension's list
        enable_word_splitting

        # Iterate over valid archieve format
        for format in ${BASH_UTILS_SUPPORTED_ARCHIEVES[@]}; do

            # Create temporary file
            echo $teststring > $file
            
            # Deduce name of the target archieve
            local archname="$arch_base_name.$extension"
            rm -f $archname

            # Create an archieve
            create_archieve $format $archname $file
            # Remove source file
            rm -f $file
            
            # Extract an archieve
            extract_archieve --directory=$distdir $archname

            # Test result
            local ret=$?
            assert equal $ret 0
            [[ $ret == 0 ]] || {
                rm -f $archname;
                continue
            }
            
            # Test content of the extracted file
            assert equal "$(cat "$distdir/$file")" "$teststring"

            # Remove temporary files
            rm -f $archname
            rm -f $distdir/$file

        done

        rm -rf $distdir

    ti

end_describe

# Test download_and_extract function
describe download_and_extract

    alias setup="cd /tmp"

    # Example URL to download
    declare url="https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz"
    # Archieve default name
    declare arch_dflt_name=$(basename $url)
    # Name of the extracted folder
    declare arch_extracted_name=${arch_dflt_name%.tgz}

    it "Check if simple archieve can be downloaded and extracted automatically"
        
        # Download and extract
        download_and_extract $url; assert equal $? 0

        # Assert, that the archieve was downloaded
        [[ -f $arch_dflt_name ]]; assert equal $? 0
        # Assert, that the extracted folder exists
        [[ -d $arch_extracted_name ]]; assert equal $? 0
        # Assert, that the folder was extracted properly
        [[ -f $arch_extracted_name/configure ]]; assert equal $? 0
        
        # Remove temporaries
        rm -rf $arch_dflt_name
        rm -rf $arch_extracted_name

    ti

    it "Check with specified download dir"
        
        # Download dir
        local download_dir="download"

        # Download and extract
        download_and_extract --arch-dir=$download_dir $url; assert equal $? 0

        # Assert, that the archieve was downloaded
        [[ -f $download_dir/$arch_dflt_name ]]; assert equal $? 0
        # Assert, that the extracted folder exists
        [[ -d $arch_extracted_name ]]; assert equal $? 0
        # Assert, that the folder was extracted properly
        [[ -f $arch_extracted_name/configure ]]; assert equal $? 0
        
        # Remove temporaries
        rm -rf $download_dir
        rm -rf $arch_extracted_name

    ti

    it "Check with specified download path"

        # Download path 
        local archieve_path="download/archieve.${arch_dflt_name##*.}"
        
        # Download and extract
        download_and_extract --arch-path=$archieve_path $url; assert equal $? 0

        # Assert, that the archieve was downloaded
        [[ -f $archieve_path ]]; assert equal $? 0
        # Assert, that the extracted folder exists
        [[ -d $arch_extracted_name ]]; assert equal $? 0
        # Assert, that the folder was extracted properly
        [[ -f $arch_extracted_name/configure ]]; assert equal $? 0
        
        # Remove temporaries
        rm -rf $(dirname $archieve_path)
        rm -rf $arch_extracted_name

    ti

    it "Check with redownload"
        
        # Download and extract
        download_and_extract $url; assert equal $? 0
        download_and_extract $url; assert equal $? 2

        # Assert, that the archieve was downloaded
        [[ -f $arch_dflt_name ]]; assert equal $? 0
        # Assert, that the extracted folder exists
        [[ -d $arch_extracted_name ]]; assert equal $? 0
        # Assert, that the folder was extracted properly
        [[ -f $arch_extracted_name/configure ]]; assert equal $? 0
        
        # Remove temporaries
        rm -rf $arch_dflt_name
        rm -rf $arch_extracted_name

    ti

    it "Check with forced redownload"
        
        # Download and extract
        download_and_extract $url; assert equal $? 0
        download_and_extract --force $url; assert equal $? 0

        # Assert, that the archieve was downloaded
        [[ -f $arch_dflt_name ]]; assert equal $? 0
        # Assert, that the extracted folder exists
        [[ -d $arch_extracted_name ]]; assert equal $? 0
        # Assert, that the folder was extracted properly
        [[ -f $arch_extracted_name/configure ]]; assert equal $? 0
        
        # Remove temporaries
        rm -rf $arch_dflt_name
        rm -rf $arch_extracted_name

    ti

end_describe
