#!/usr/bin/env bash
# ====================================================================================================================================
# @file     files.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 1:05:39 am
# @modified Tuesday, 9th November 2021 2:58:19 am
# @project  BashUtils
# @brief
#    
#    Test suite for functions from lib/files/files.bash module
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

# Test get_file_lines_num function
describe get_file_lines_num

    alias setup='file=$(mktemp) || return'
    alias teardown='rm "$file"'

    it "Test"
    
        # Write some text to the file
        echo "It is"            >> "$file"
        echo "a multiline"      >> "$file"
        echo "text"             >> "$file"
        echo "written"          >> "$file"
        echo "to the temporary" >> "$file"
        echo "file"             >> "$file"
        
        local result

        # Read number of lines
        result="$(get_file_lines_num "$file")"; assert equal $? "0"
        assert equal "$result" "6"
 
    ti

end_describe

# Test get_file_line function
describe get_file_line

    alias setup='file=$(mktemp) || return'
    alias teardown='rm "$file"'

    it "Test"
    
        # Write some text to the file
        echo "It is"            >> "$file"
        echo "a multiline"      >> "$file"
        echo "text"             >> "$file" # Tested line
        echo "written"          >> "$file"
        echo "to the temporary" >> "$file"
        echo "file"             >> "$file"
        
        local result

        # Write a line to the file
        result="$(get_file_line "$file" 3)"; assert equal $? "0"
        assert equal "$result" "text"
 
    ti

end_describe

# Test get_file_lines_num function
describe get_file_lines_num

    alias setup='file=$(mktemp) || return'
    alias teardown='rm "$file"'

    it "Test"
    
        # Write some text to the file
        echo "It is"            >> "$file"
        echo "a multiline"      >> "$file"
        echo "text"             >> "$file"
        echo "written"          >> "$file"
        echo "to the temporary" >> "$file"
        echo "file"             >> "$file"
        
        local result

        # Write a line to the file
        result="$(get_file_lines_num "$file")"; assert equal $? "0"
        assert equal "$result" "6"
 
    ti

end_describe

# Test print_lines function
describe print_lines

    alias setup='file=$(mktemp) || return'
    alias teardown='rm "$file"'

    it "Write a single line to file"
    
        local line="A single line text"

        # Write a line to the file
        print_lines "$line" > "$file";

        # Check line count
        assert equal "$(get_file_lines_num "$file")" "1"
        # Cheeck line's content
        assert equal "$(get_file_line "$file" 1)" "$line"

    ti

    it "Write multiple lines to file"
    
        local line1="A single line text (1)"
        local line2="A single line text (2)"
        local line3="A single line text (3)"
        local line4="A single line text (4)"

        # Write a line to the file
        print_lines   \
            "$line1"  \
            "$line2"  \
            "$line3"  \
            "$line4"  \
        > "$file"

        # Check line count
        assert equal "$(get_file_lines_num "$file")" "4"
        # Cheeck line's content
        assert equal "$(get_file_line "$file" 3)" "$line3"

    ti

end_describe

# Test get_file_extension function
describe get_file_extension

    it "Get extension of the non-extension file"
    
        local result=''

        # Write a line to the file
        result=$(get_file_extension "file"); assert equal $? 1
        assert equal "$result" ""

    ti

    it "Get extension of the file with a single extension"
    
        local result

        # Write a line to the file
        result=$(get_file_extension "file.txt"); assert equal $? 0
        assert equal "$result" "txt"

    ti

    it "Get extension of the file with a double extension"
    
        local result

        # Write a line to the file
        result=$(get_file_extension "file.txt.gz"); assert equal $? 0
        assert equal "$result" "gz"

    ti

end_describe

# Test remove_file_extension function
describe remove_file_extension

    it "Remove file extension from no extension file"
    
        local result=''

        # Write a line to the file
        result=$(remove_file_extension "file"); assert equal $? 1
        assert equal "$result" "file"

    ti

    it "Remove file extension from no extension file with option "
    
        local result=''

        # Write a line to the file
        result=$(remove_file_extension -z "file"); assert equal $? 1
        assert equal "$result" ""

    ti

    it "Remove file extension from no extension miltiword file with option "
    
        local result=''

        # Write a line to the file
        result=$(remove_file_extension -z "file with spaces"); assert equal $? 1
        assert equal "$result" ""

    ti

    it "Remove file extension from single extension file"
    
        local result=''

        # Write a line to the file
        result=$(remove_file_extension "file.txt"); assert equal $? 0
        assert equal "$result" "file"

    ti

    it "Remove file extension from double extension file"
    
        local result=''

        # Write a line to the file
        result=$(remove_file_extension "file.txt.gz"); assert equal $? 0
        assert equal "$result" "file.txt"

    ti

    it "Remove file extension from file with spaces in name"
    
        local result=''

        # Write a line to the file
        result=$(remove_file_extension "file with some spaces in name.txt"); assert equal $? 0
        assert equal "$result" "file with some spaces in name"

    ti
    
end_describe

