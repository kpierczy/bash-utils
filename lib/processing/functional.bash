#!/usr/bin/env bash
# ====================================================================================================================================
# @file     functional.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 6:14:24 pm
# @modified Thursday, 11th November 2021 1:18:36 am
# @project  bash-utils
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
function map () {

    # Arguments
    local fun_=$1

    # Local variables
    local arg_

    # Apply function to all elements on the stdin
    while read -r arg; do
        ! [[ "$fun_" == *\$* ]]
        case $? in
            # If @p fun is a regular function
            0 ) "$fun_" "$arg_";;
            # If @p fun is a 'lambda'
            * ) set -- "$arg_"
                eval "echo "$fun_""
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
function filter () {

    # Arguments
    local rule_=$1

    # Local variables
    local arg_

    # Apply function to all elements on the stdin
    while read -r arg; do
        ! [[ "$rule_" == *\$* ]]
        case $? in
            # If @p fun is a regular function
            0 ) "$rule_" "$arg_" && echo "$arg_";;
            # If @p fun is a 'lambda'
            * ) set -- "$arg_"
                eval ""$rule_" && echo $1"
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
# @options
#     
#    -a|--accumulator  initial value of the acumulator; if not 
#                      given, initial accumulator is read from the
#                      first element passed to the stdin
# -------------------------------------------------------------------
function reduce () {

    # Arguments
    local acc_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-a|--accumulator',acc
    )
    
    # Parse arguments to a named array
    parse_options
    
    # Parse arguments
    acc_="${posargs[0]}"

    # Parse options
    local accumulator_="${options[acc]:-}"

    # -------------------------------------------------

    # Local variables
    local arg_

    # Read initial value of the accumulator
    ! is_var_set_non_empty accumulator_ && read -r accumulator_
    # Apply function to all elements on the stdin
    while read -r arg_; do
        ! [[ "$acc_" == *\$* ]]
        case $? in
            # If @p fun is a regular function
            0 ) accumulator_="$($acc $accumulator_ $arg_)";;
            # If @p fun is a 'lambda'
            * ) set -- "$accumulator_" "$arg_"
                eval "accumulator=\$(echo "$acc_")"
                ;;
        esac
    done

    # Print result
    echo "$accumulator_"

}
