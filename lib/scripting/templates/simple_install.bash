#!/usr/bin/env bash
# ====================================================================================================================================
# @file       simple_install.bash
# @author     Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @maintainer Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date       Thursday, 4th November 2021 4:14:44 pm
# @modified   Thursday, 12th May 2022 9:46:14 pm
# @project    bash-utils
# @brief
#    
#    Basic script template for simple software installation scripts
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================== Main ============================================================== #

function main() {

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == $PARSEARGS_HELP_REQUESTED ]]; then
        return
    elif [[ $ret != $PARSEARGS_SUCCESS ]]; then
        return $ret
    fi

    # Run installation routine
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
