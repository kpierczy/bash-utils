#!/usr/bin/env bash
# ====================================================================================================================================
# @file     shpec_support.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 1:26:22 am
# @modified Wednesday, 3rd November 2021 2:07:31 am
# @project  Winder
# @brief
#    
#    Set of shpec-specific helper aliases
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# -------------------------------------------------------------------
# @brief Replacement for shpec's 'it' opening a subprocess context
#    for a test to be run and performing an additional reset
#    of the @var _shpec_failures variable of the shpec's context.
#    This way the test will count only it's own failures noticed
#    by the 'assert' calls.
#    Additionally the if the 'setup' alias is set before it block,
#    it will be called and unset in turn. This mechanism makes 
#    provides a clean way to define test's 'setup' routine.
#    Sets a 'teardown' routine (if set by alias) to be called
#    at the EXIT signal of the subshell running the test case.
#
# @note @var _shpec_failures is an accumulated number of failed
#    tests hat is followed by the shpec.
#
# @example
#    
#    describe hello_file
#       alias setup='file=$(mktemp) || return'
#       alias teardown='rm "$file"'
#   
#       it "writes 'hello, world!' to a file"
#           hello_file "$file"
#           assert equal "hello, world!" "$(<"$file")"
#       ti
#    end_describe
#
# -------------------------------------------------------------------
alias it='(_shpec_failures=0; alias setup &>/dev/null && { setup; unalias setup; alias teardown &>/dev/null && trap teardown EXIT ;}; it'

# -------------------------------------------------------------------
# @brief Replacement for shpec's 'end' completing call to the 'it'.
#    It makes the subshell return an @var _shpec_failures that is
#    in turn added to the @var _shpec_failures of the main context.
#    Additionally, @var _shpec_examples is incremented.
#
# @note @var _shpec_examples hold the number of tests that has been
#    run by the shpec.
#
# @example
#    
#    describe hello_file
#       alias setup='file=$(mktemp) || return'
#       alias teardown='rm "$file"'
#   
#       it "writes 'hello, world!' to a file"
#           hello_file "$file"
#           assert equal "hello, world!" "$(<"$file")"
#       ti
#    end_describe
#
# -------------------------------------------------------------------
alias ti='return "$_shpec_failures"); (( _shpec_failures += $?, _shpec_examples++ ))'


# -------------------------------------------------------------------
# @brief Replacement for shpec's 'end' completing call to the 
#    'describe' block. Unaliases setup and teardown routines of the
#    test case.
#
# @example
#    
#    describe hello_file
#       alias setup='file=$(mktemp) || return'
#       alias teardown='rm "$file"'
#   
#       it "writes 'hello, world!' to a file"
#           hello_file "$file"
#           assert equal "hello, world!" "$(<"$file")"
#       ti
#    end_describe
#
# -------------------------------------------------------------------
alias end_describe='end; unalias setup teardown 2>/dev/null'
