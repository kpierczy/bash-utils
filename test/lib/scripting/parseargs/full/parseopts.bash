#!/usr/bin/env bash
# ====================================================================================================================================
# @file     strict_mode_test.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 1:58:55 am
# @modified Thursday, 17th February 2022 7:15:43 pm
# @project  Winder
# @brief
#    
#    Unit tests of the 'strict_mode' module of te library
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source testing helpers
source $BASH_UTILS_HOME/lib/test/shpec_support.bash

# Enable macros' expansion
shopt -s expand_aliases

# Source library
source $BASH_UTILS_HOME/source_me.bash

# =========================================================== Test cases =========================================================== #

# Test parseopts() function from perseargs/full submodule
describe parseopts_full

    it "Check if basic option parsing works"

        # Options' definitions
        declare -A opt_a_def=( [format]="-a|--opt-a" [name]="a" [type]="f"                                 )
        declare -A opt_b_def=( [format]="-b|--opt-b" [name]="b" [type]="f"                                 )
        declare -A opt_c_def=( [format]="-c|--opt-c" [name]="c" [type]="f"                                 )
        declare -A opt_d_def=( [format]="-d|--opt-d" [name]="d" [type]="s" [variants]="var1 | var2 | var3" )
        declare -A opt_e_def=( [format]="-e|--opt-e" [name]="e" [type]="i" [range]="10:100"                )
        # UBAD list for options
        declare -a opts_definitions=(
            opt_a_def
            opt_b_def
            opt_c_def
            opt_d_def
            opt_e_def
        )

        # Arguments
        declare -a options
        options+=( -h )
        options+=( -v )
        options+=( --flag-default-undefined )
        declare -a args
        args+=( -a )
        args+=( -b )
        args+=( --opt-d=var1 )
        args+=( --opt-e=11 )
        args+=( parg1 )
        args+=( parg2 )
        
        # Parsed options (out)
        declare -A opts
        # Parsed positional arguments (out)
        declare -a pargs

        # Parse options
        parseopts ${options[@]} -- args opts_definitions opts pargs
        # verify result
        assert equal $? 0

        # Verify options
        assert equal "${pargs[0]}" "parg1"
        assert equal "${pargs[1]}" "parg2"
        # Verify unparsed positional arguments
        is_var_set pargs[2]
        assert equal $? 1

        # Verify optional arguments
        assert equal "${opts[a]}" "0"
        assert equal "${opts[b]}" "0"
        assert equal "${opts[d]}" "var1"
        assert equal "${opts[e]}" "11"
        # Verify unparsed optional arguments
        is_var_set opts[c]
        assert equal $? 1

    ti

end_describe

# Test generate_options_description() function from perseargs/full submodule
describe generate_options_description

    it "Check if auto-generation of options' description works"
        
        # Options' definitions
        declare -A opt_a_def=( [format]="-a|--opt-a"          [name]="a" [type]="f"                                 [help]="some description of a some description of a some description of a some description of a some description of a some description of a" )
        declare -A opt_b_def=( [format]="-b|--opt-bbbbbbbbbb" [name]="b" [type]="f"                                 [help]="some description of b some description of b some description of b some description of b some description of b some description of b" )
        declare -A opt_c_def=( [format]="-c|--opt-cc"         [name]="c" [type]="f"                                 [help]="some description of c some description of c some description of c some description of c some description of c some description of c" )
        declare -A opt_d_def=( [format]="-d|--opt-dddd"       [name]="d" [type]="s" [variants]="var1 | var2 | var3" [help]="some description of d some description of d some description of d some description of d some description of d some description of d" )
        declare -A opt_e_def=( [format]="-e|--opt-eeeee"      [name]="e" [type]="i" [range]="10:100"                [help]="some description of e some description of e some description of e some description of e some description of e some description of e" )
        # UBAD list for options
        declare -a opts_definitions=(
            opt_a_def
            opt_b_def
            opt_c_def
            opt_d_def
            opt_e_def
        )
        
        # Generate output
        local output=$(generate_options_description opts_definitions)

    ti

end_describe
