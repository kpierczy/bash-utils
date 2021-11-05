#!/usr/bin/env bash
# ====================================================================================================================================
# @file     functional.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 6:14:24 pm
# @modified Thursday, 4th November 2021 11:23:14 pm
# @project  BashUtils
# @brief
#    
#    Functions performing general-purpose manipulations concerning applying a function to a collection
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Calls @p fun function on each element read from the stdin
#
# @param fun
#    function to be mapped; either name of the function or a string
#    beggining with '$' representing an expression to be evaluated
#    (poor-man's lambda)
# -------------------------------------------------------------------
map () {

    # Arguments
    local fun=$1

    # Local variables
    local arg

    # Apply function to all elements on the stdin
    while read -r arg; do
        ! [[ $fun == *\$* ]]
        case $? in
            # If @p fun is a regular function
            0 ) $fun $arg;;
            # If @p fun is a 'lambda'
            * ) set -- $arg
                eval "echo $fun"
                ;;
        esac
    done;:

}

# -------------------------------------------------------------------
# @brief Filters arguments read from the stdin according to the
#    @p rule functor (prints to the stdout only thos argments
#    that passed to the @p rule result in '0' exit code)
#
# @param rule
#    filtering function; either name of the function or a string
#    beggining with '$' representing an expression to be evaluated
#    as a filter (poor-man's lambda)
# -------------------------------------------------------------------
filter () {

    # Arguments
    local rule=$1

    # Local variables
    local arg

    # Apply function to all elements on the stdin
    while read -r arg; do
        ! [[ $rule == *\$* ]]
        case $? in
            # If @p fun is a regular function
            0 ) $rule $arg && echo $arg;;
            # If @p fun is a 'lambda'
            * ) set -- $arg
                eval "$rule && echo $1"
                ;;
        esac
    done;:

}

# -------------------------------------------------------------------
# @brief Reduces arguments read from the stdin according to the
#    @p acc functor (prints to the stdout accumulated result)
#
# @param acc
#    accumulating function; either name of the function or a string
#    beggining with '$' representing an expression to be evaluated
#    as an accumulator (poor-man's lambda); takes two arguments:
# 
#       accumulated - accumulated value
#       item        - next item from the input
#
# @param accumulator (optional)
#    initial value of the acumulator; if not given, initial 
#    accumulator is read from the first element passed to the stdin
# -------------------------------------------------------------------
reduce () {

    # Arguments
    local acc=$1
    local accumulator=${2:-}

    # Local variables
    local arg

    # Read initial value of the accumulator
    (( $# == 1 )) && read -r accumulator
    # Apply function to all elements on the stdin
    while read -r arg; do
        ! [[ $acc == *\$* ]]
        case $? in
            # If @p fun is a regular function
            0 ) accumulator=$($acc $accumulator $arg);;
            # If @p fun is a 'lambda'
            * ) set -- $accumulator $arg
                eval "accumulator=\$(echo $acc)"
                ;;
        esac
    done

    # Print result
    echo $accumulator

}
