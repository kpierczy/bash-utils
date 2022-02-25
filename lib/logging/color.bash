#!/usr/bin/env bash
# ====================================================================================================================================
# @file     color.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 24th February 2022 6:55:48 pm
# @modified Thursday, 24th February 2022 8:02:45 pm
# @project  bash-utils
# @brief
#    
#    File containing helper functions dealing with bash colors
#    
# @copyright Krzysztof Pierczyk © 2022
# @see https://linuxcommand.org/lc3_adv_tput.php
# ====================================================================================================================================

# ======================================================== Probing functions ======================================================= #

# ---------------------------------------------------------------------------------------
# @brief Prints all sample of all foregaround colours present in the shell 
# @outputs
#     sample of foreground colors
# ---------------------------------------------------------------------------------------
function probe_foreground_colors() {

    # Get number of oclors
    local colors_num=$(tput colors)
    # Get highest color code 
    local color_max
    (( color_max = $colors_num - 1 ))
    # Get array of color codes
    local -a color_codes=( $(seq 0 $color_max) )

    local color

    # Print colors
    for color in "${color_codes[@]}"; do 
        echo -en "$(tput setaf ${color})${color} ";
        
    done
    
    # Print newline (reset color)
    echo $(tput sgr0)
}

# ---------------------------------------------------------------------------------------
# @brief Prints all sample of all background colours present in the shell 
# @outputs
#     sample of background colors
# ---------------------------------------------------------------------------------------
function probe_backround_colors() {

    # Get number of oclors
    local colors_num=$(tput colors)
    # Get highest color code 
    local color_max
    (( color_max = $colors_num - 1 ))
    # Get array of color codes
    local -a color_codes=( $(seq 0 $color_max) )

    local color

    # Print colors
    for color in "${color_codes[@]}"; do 
        echo -en "$(tput setab ${color})${color} ";
        
    done
    
    # Print newline (reset color)
    echo $(tput sgr0)
}

# ---------------------------------------------------------------------------------------
# @brief Prints all sample of all foreground and background colours present in the shell 
# @outputs
#     sample of foreground and background colors
# ---------------------------------------------------------------------------------------
function probe_colors() {

    # Probe foreground colors
    probe_foreground_colors
    # Probe background colors
    probe_backround_colors
    
}

# ======================================================= Setting attributes ======================================================= #

# ---------------------------------------------------------------------------------------
# @brief Resets all visual attributes of the terminal 
# ---------------------------------------------------------------------------------------
function reset_colors() {
    tput sgr0
}

# ---------------------------------------------------------------------------------------
# @brief Set the foreground color with index @p color
#
# @param color
#    index of the foreground color to be returned
# ---------------------------------------------------------------------------------------
function set_fcolor() {
    
    # Arguments
    local color="$1"

    # Output the color
    tput setaf ${color}
}

# ---------------------------------------------------------------------------------------
# @brief Set background color with index @p color
#
# @param color
#    index of the background color to be returned
# @outputs
#     code of the background color with index @p color
# ---------------------------------------------------------------------------------------
function set_bcolor() {
    
    # Arguments
    local color="$1"

    # Output the color
    tput setab ${color}
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to bold
# ---------------------------------------------------------------------------------------
function set_bold() { 
    tput bold 
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to underlined
# ---------------------------------------------------------------------------------------
function set_underling()   { 
    tput smul 
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to non-underlined
# ---------------------------------------------------------------------------------------
function unset_underling() { 
    tput rmul 
}

# ---------------------------------------------------------------------------------------
# @brief Reverses attributes of shell colors
# ---------------------------------------------------------------------------------------
function reverse_colors() { 
    tput rev 
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to blinking
# ---------------------------------------------------------------------------------------
function set_blinking() { 
    tput blink 
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to invisible
# ---------------------------------------------------------------------------------------
function set_invisible() { 
    tput invis 
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to 'standout' mode
# ---------------------------------------------------------------------------------------
function set_standout() { 
    tput smso 
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell text to 'non-standout' mode
# ---------------------------------------------------------------------------------------
function unset_standout() { 
    tput rmso 
}

# ========================================================= Colors setters ========================================================= #

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Black
# ---------------------------------------------------------------------------------------
function set_fblack() { 
    set_fcolor '0'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Black
# ---------------------------------------------------------------------------------------
function set_bblack() { 
    set_bcolor '0'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Red
# ---------------------------------------------------------------------------------------
function set_fred() { 
    set_fcolor '1'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Red
# ---------------------------------------------------------------------------------------
function set_bred() { 
    set_bcolor '1'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Green
# ---------------------------------------------------------------------------------------
function set_fgreen() { 
    set_fcolor '2'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Green
# ---------------------------------------------------------------------------------------
function set_bgreen() { 
    set_bcolor '2'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Yellow
# ---------------------------------------------------------------------------------------
function set_fyellow() { 
    set_fcolor '3'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Yellow
# ---------------------------------------------------------------------------------------
function set_byellow() { 
    set_bcolor '3'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Blue
# ---------------------------------------------------------------------------------------
function set_fblue() { 
    set_fcolor '4'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Blue
# ---------------------------------------------------------------------------------------
function set_bblue() { 
    set_bcolor '4'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Magenta
# ---------------------------------------------------------------------------------------
function set_fmagenta() { 
    set_fcolor '5'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Magenta
# ---------------------------------------------------------------------------------------
function set_bmagenta() { 
    set_bcolor '5'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Cyan
# ---------------------------------------------------------------------------------------
function set_fcyan() { 
    set_fcolor '6'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Cyan
# ---------------------------------------------------------------------------------------
function set_bcyan() { 
    set_bcolor '6'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to White
# ---------------------------------------------------------------------------------------
function set_fwhite() { 
    set_fcolor '7'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to White
# ---------------------------------------------------------------------------------------
function set_bwhite() { 
    set_bcolor '7'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Gray
# ---------------------------------------------------------------------------------------
function set_fgray() { 
    set_fcolor '8'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Gray 
# ---------------------------------------------------------------------------------------
function set_bgray() { 
    set_bcolor '8'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell foreground color to Default (code choosen manually to enable
#    only the color and not other shell's attributes)
# ---------------------------------------------------------------------------------------
function set_fdefault() { 
    set_fcolor '250'
}

# ---------------------------------------------------------------------------------------
# @brief Sets shell background color to Default
# ---------------------------------------------------------------------------------------
function set_bdefault() { 
    set_bcolor '9'
}
