#!/usr/bin/env python3
# ====================================================================================================================================
# @file     getoptdef.py
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 10th November 2021 2:57:02 am
# @modified Friday, 12th November 2021 12:31:54 am
# @project  bash-utils
# @brief
#    
#    Script produces a bash-format array containing definitions of all options switches of the given programs
#    To do so, script parsed output of the --help option for the given program. It assumes that the list of options
#    has a standard GNU format (i.e. -<shortopt>, --<longopt>[=<SOME_VALUE>] <description>). 
#
# @note Utility was tested only with the `wget` command and probably should be extended to work with other ones
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

import re
import regex
import subprocess

# ========================================================== Configruation ========================================================= #

# Name of the program to be parsed
PROGRAM="wget"

# Output file
OUTPUT_FILE="wget.bash"

# ============================================================= Process ============================================================ #

# Get lines of the wget's help
lines=subprocess.run([PROGRAM, "--help"], capture_output=True).stdout.decode('UTF-8').split('\n')

# Iterate over lines
options=[]
i = 0 
for line in lines:

    # Try to find option definition in the line starting from the '-[a-zA-Z]' (short option)
    short_matches = re.findall("-[a-zA-Z]*, *--[a-zA-Z-=]+", line)
    # Try to find option definition in the line starting from the '--[a-zA-Z-]' (long option)
    long_matches = re.findall("--[a-zA-Z-=]+", line)
    
    # If definition found, add if to list
    if len(short_matches) != 0:
        match=short_matches[0]
    elif len(long_matches) != 0:
        match=long_matches[0]
    else:
        continue

    # Remove newline and spaces from the option's deinition
    match=match.replace('\n', '')
    match=match.replace('\r', '')
    match=match.replace(' ', '')
    # Replace ',' with "|"
    match=match.replace(',', '|')
    # Qdd option's definition to the list
    options.append(match)

# Get length of the longest option's definition
max_len = len(max(options, key=len))
# Justify all options right
for i, opt in enumerate(options):
    options[i] = " " * (max_len - len(opt)) + opt

# Loop the options
for i, opt in enumerate(options):
    
    # Find long name of the option
    lname = re.findall("--[a-z\-]*", opt)[0]
    # Remove opening '--
    lname = lname.replace('--', '')
    # Replace '-' with '_'
    lname = lname.replace('-', '_')
    # Append converted name to the option's definition
    opt = opt + ',' + lname

    # If valued option
    if "=" in opt:

        # Find '=...' substring
        value = re.findall("=[a-zA-Z]*", opt)[0]
        # Remove it from the definition
        opt = opt.replace(value, '')
        # Add compensating number of spaces to the beggining of the line
        opt = " " * len(value) + opt
        
    # If flag option
    else:

        # Add ',f' indicator
        opt = opt + ',' + 'f'
        
    # Covert option's format with quotation
    format = re.findall("-.*-[a-zA-Z-=]*,", opt)[0]
    opt = opt.replace(format[:-1], "'" + format[:-1] + "'")

    # Save converted line
    options[i] = opt

# Create set of lines of the result file
lines = [ "local -a opt_definitions=(" ]
lines = lines + options
lines.append(")")

# Write result to the file
with open(OUTPUT_FILE, "w") as f:
    for i in lines:
        f.write(i + "\n")