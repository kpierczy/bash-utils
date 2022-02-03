#!/usr/bin/env python3
# ====================================================================================================================================
# @file     extract_zip_with_progress.py
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Thursday, 11th November 2021 10:54:02 pm
# @modified Friday, 12th November 2021 12:31:49 am
# @project  bash-utils
# @brief
#    
#    Simple script extracting zip with a progress bar
# 
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Command line arguments
import argparse
# ZIP file's extraction
import zipfile
from tqdm import tqdm

# ========================================================= Parse arguments ======================================================== #

# Description
parser = argparse.ArgumentParser(description='Extracts files form the ZIP directory')

# Path to the archieve
parser.add_argument(
    'archieve', type=str, 
    help='path to the archieve to be extracted'
)

# Destination directory (option)
parser.add_argument(
    '-d', '--directory', dest='dir', type=str,
    help='destination directory for extracted files'
)
# Progress bar (option)
parser.add_argument(
    '-p' ,'--show-progress', dest='progress', action='store_true',
    help='if set, progress bar will be displayed'
)

# Parse arguments
args = parser.parse_args()

# ======================================================== Extract archieve ======================================================== #

# Try to extract the file
try:

    # Open the file
    with zipfile.ZipFile(args.archieve) as zip_ref:
    
        # If no progress bar requested
        if not args.progress:
            zip_ref.extractall(args.dir)
        # If progress bar requested
        else:
            for member in tqdm(zip_ref.infolist(), desc='Extracting '):
                try:
                    zip_ref.extract(member, args.dir)
                except zipfile.error as e:
                    pass

# Could not open the file
except BaseException as err:
    exit(1)
    