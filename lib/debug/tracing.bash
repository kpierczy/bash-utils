#!/usr/bin/env bash
# ====================================================================================================================================
# @file     tracing.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 4:05:49 am
# @modified Tuesday, 9th November 2021 3:04:23 am
# @project  BashUtils
# @brief
#    
#    Set of routines providing an interface for bash script's tracing
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Traceback handler designed to be used at ERR signal's 
#    reception
# -------------------------------------------------------------------
traceback () {

    # Parameter
    local -i rc=$?
    
    # Enable tracing
    set +o xtrace

    # Local variables
    local -i frame=0
    local IFS
    local expression
    local result

    # Enable word-splitting
    IFS=' '
    # Start the traceback info
    echo $'\nTraceback:'
    # Iterate over the failure fram stack
    while result=$(caller $frame); do

        # Set frame's components as positional arguments
        set -- $result

        # If first frame is being processed, ...
        (( frame == 0 )) && {
            printf -v expression '%s s/^[[:space:]]*// p' "$1"
            echo -n '  Command: '
            sed -n "$expression" "$3"
        }
        # Print trace log
        echo "  $3:$1:in '$2'"
        # Increment loop counter
        frame+=1
        
    done
    
    printf '  Exit status: %s\n\n' $rc
    return $rc
    
} >&2
