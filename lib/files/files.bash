#!/usr/bin/env bash
# ====================================================================================================================================
# @file     modifying.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:04:36 am
# @modified Thursday, 4th November 2021 12:02:50 am
# @project  BashUtils
# @brief
#    
#    Set of handy functions related to files' manipulation
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Adds @p string to the @p file with an optional @p comment
#
# @p file
#    destination file
# @param string
#    string to be added to the file
# @param comment (optional)
#    comment descibing the @p string
# -------------------------------------------------------------------
add_to_file() {

    local dst=$1
    local string=$2
    local comment=$3

    # Append strin and comment (if passed)
    if [[ $# -gt 1 ]]; then
        echo "# $comment" >> $dst;
        echo "$string" >> $dst;
    else
        echo "$string" >> $dst;
    fi

    # End with an empty line
    echo "" >> $FILE;

}

# -------------------------------------------------------------------
# @brief Adds @p string as a new line to the ~/.bashrc if @p string
#    is not present. Additional @p comment can be written before
#    @c string
#
# @param string
#    string to be added to ~/.bashrc
# @param comment (optional)
#    comment descibing the @p string
# -------------------------------------------------------------------
add_to_bashrc() {

    local string=$1
    local comment=$2
    
    # Output file
    local FILE=~/.bashrc

    # Check if line is present in .bashrc
    if ! [[ -f $FILE ]] || ! grep "$string" $FILE > /dev/null; then

        add_to_file "$FILE" "$string" "$comment"

    fi
}
