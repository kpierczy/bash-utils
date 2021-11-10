#!/usr/bin/env bash
# ====================================================================================================================================
# @file     tracing.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 4:05:49 am
# @modified Wednesday, 10th November 2021 5:54:32 pm
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
function traceback () {

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
