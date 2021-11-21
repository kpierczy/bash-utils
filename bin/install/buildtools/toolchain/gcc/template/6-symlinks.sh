#!/usr/bin/bash -e
# ====================================================================================================================================
# @file     config.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 21st July 2021 10:50:38 pm
# @modified Thursday, 22nd July 2021 7:10:07 pm
# @project  Winder
# @brief
#    
#    Script creating symbolic links for built binaries
#    
# @author Lucjan Bryndza (original source: https://github.com/lucckb/isixrtos/tree/master/extras/toolchain/mac)
# @maintainer Krzysztof Pierczyk
# ====================================================================================================================================

# Source config file
source $PROJECT_HOME/scripts/toolchain/config.bash

# Create symbolic links to binaries
for i in /usr/local/arm-none-eabi-gcc/*; do
	ln -s $i /usr/local/bin
done
