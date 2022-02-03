#!/usr/bin/env bash
# ====================================================================================================================================
# @file     base.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 4th November 2021 4:14:44 pm
# @modified Friday, 5th November 2021 2:20:35 pm
# @project  bash-utils
# @brief
#    
#    Basic script template covering disabling words-splitting, performing exit-on-source routine and entering the strict mode. 
#    This file should be sourced after defining the main() function in the templated script.
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Disable default words' splittinf
disable_word_splitting

# If script was sourced, exit
is_sourced 1 && return
# Enable strict mode
strict_mode on

# Run script
main $@ 
