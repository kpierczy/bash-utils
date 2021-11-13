#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parsepargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Saturday, 13th November 2021 7:53:47 pm
# @project  BashUtils
# @brief
#    
#    Positional-arguments-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses list of positional arguments named @p pargs based on the 
#    @p args_definitions UBAD list. Writes parsed arguments to the hash array named 
#    @p nargs if an argument is named or to the array named @P uargs if not.
#
#
# @param pargs
#    name of the array holding positional arguments to be parsed
# @param args_definitions
#    name of the UBAD list array holding arguments' definitions
# @param nargs (out)
#    name of the hash array where the parsed named arguments will be written into
# @param uargs (out)
#    name of the array where the parsed unnamed arguments will be written into
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error
#
# @options (core)
#
#  -g INT,            --arg-num=INT  required number of positional arguments
#  -m INT,        --arg-num-min=INT  minimal number  of positional arguments 
#                                    (overwritten by --arg-num)
#  -x INT,        --arg-num-max=INT  maximal number  of positional arguments 
#                                    (overwritten by --arg-num)
#  
# @options (script-oriented)
# 
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails
#
# @options (minor)
# 
#  -r,                        --raw  by default, elements of the [variants] and 
#                                    [range] lists of the UBAD table are trimmed
#                                    after being parsed (edge whitespace characters 
#                                    are removed). If this flag is setl this behaviour
#                                    is suspended
#  -c,   --without-int-verification  if set, no integer-typed arguments validation is
#                                    performed
#  -t,  --without-path-verification  if set, no path-typed arguments validation is
#                                    performed
#
# @environment
#    
#                       LOG_CONTEXT  context for the logs printed by the function in the
#                                    --verbose mode
#
# ---------------------------------------------------------------------------------------
function parsepargs() {
    
}
