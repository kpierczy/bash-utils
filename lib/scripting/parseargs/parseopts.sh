#!/usr/bin/env bash
# ====================================================================================================================================
# @file     parseopts.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 13th November 2021 7:33:06 pm
# @modified Saturday, 13th November 2021 7:52:50 pm
# @project  BashUtils
# @brief
#    
#    Options-parsing routines of the "parseargs" module
#    
# @see parseargs.bash
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses list of arguments named @p args based on the @p opts_definitions UBAD
#    list. Writes parse options to the hash array named @p opts and parsed positional
#    arguments into the array named @p pargs
#
#
# @param args
#    name of the array holding arguments to be parsed
# @param opts_definitions
#    name of the UBAD list array holding options' definitions
# @param opts (out)
#    name of the hash array where the parsed options will be written into
# @param pargs (out)
#    name of the array where the parsed positional arguments will be written into
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if '-h|--help' option has been parsed
#
# @options (script-oriented)
# 
#  -v,                    --verbose  if set, the verbose logs will be printed to the
#                                    stdout when the parsing process fails
#  -r,                        --raw  by default, elements of the [variants] and 
#                                    [range] lists of the UBAD table are trimmed
#                                    after being parsed (edge whitespace characters 
#                                    are removed). If this flag is setl this behaviour
#                                    is suspended
#  -f,     --flag-default-undefined  by default, flag arguments are set to 1 when not 
#                                    parsed (in bash '0' means true and '1' means false)
#                                    and set to 0 when parsed. If this flag is set, 
#                                    the non-parsed flag-typed arguments will stay
#                                    undefined in 'opts' hash array 
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
function parseopts() {
    
}
