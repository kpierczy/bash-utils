#!/usr/bin/env bash
# ====================================================================================================================================
# @file     base.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 21st February 2022 7:05:51 pm
# @modified Tuesday, 22nd February 2022 1:33:31 am
# @project  bash-utils
# @brief
#    
#    Basic usage example for `parseargs` V2.0
#    
# @copyright Krzysztof Pierczyk © 2022
# ====================================================================================================================================

source source_me.bash

# ============================================================== Test ============================================================== #

declare description="This is a test of the \`parseargs\` parser"
declare cmd_name="test"

# ============================================================= Options ============================================================ #

# Options' definitions
declare -A a_opt_def=( [format]="-a|--opt-a"          [name]="a" [type]="p"                                 [help]="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris porttitor varius congue. Morbi dapibus mi sed mattis rhoncus" )
declare -A b_opt_def=( [format]="-b|--opt-bbbbbbbbbb" [name]="b" [type]="f"                                 [help]="Praesent tempor eros vel lectus efficitur hendrerit. Sed pharetra condimentum leo quis molestie" )
declare -A c_opt_def=( [format]="-c|--opt-cc"         [name]="c" [type]="f"                                 [help]="Nam egestas massa a enim consequat varius. Nulla non maximus justo. Nullam vitae laoreet nibh, luctus facilisis mauris. Aenean tempus faucibus lacus, eu rutrum ante tincidunt id" )
declare -A d_opt_def=( [format]="-d|--opt-dddd"       [name]="d" [type]="s" [variants]="var1 | var2 | var3" [help]="Fusce tincidunt, ligula in egestas tempor, lacus ligula pulvinar est, at varius libero ante nec ipsum. Donec tincidunt erat vel erat consectetur hendrerit. Ut ultrices placerat orci id tempor" )
declare -A e_opt_def=( [format]="-e|--opt-eeeee|-f"   [name]="e" [type]="i" [range]="10:100"                [help]="Cras nec turpis at lorem ornare lacinia elementum in lacus. Aenean eget nulla purus. Nullam ultricies hendrerit volutpat" )
# UBAD list for options
declare -a opts_def=(
    $(declare -A | grep -oE -- " [[:alnum:]]*_opt_def")
)

# Parsed options (out)
declare -A opts

# =========================================================== Positionals ========================================================== #

# Options' definitions
declare -A a_parg_def=( [format]="ARG_A"          [name]="a" [type]="p"                                 [help]="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris porttitor varius congue. Morbi dapibus mi sed mattis rhoncus" )
declare -A b_parg_def=( [format]="ARG_BBBBBBBBBB" [name]="b" [type]="s"                                 [help]="Praesent tempor eros vel lectus efficitur hendrerit. Sed pharetra condimentum leo quis molestie" )
declare -A c_parg_def=( [format]="ARG_CC"         [name]="c" [type]="s"                                 [help]="Nam egestas massa a enim consequat varius. Nulla non maximus justo. Nullam vitae laoreet nibh, luctus facilisis mauris. Aenean tempus faucibus lacus, eu rutrum ante tincidunt id" )
declare -A d_parg_def=( [format]="ARG_DDDD"       [name]="d" [type]="s" [variants]="var1 | var2 | var3" [help]="Fusce tincidunt, ligula in egestas tempor, lacus ligula pulvinar est, at varius libero ante nec ipsum. Donec tincidunt erat vel erat consectetur hendrerit. Ut ultrices placerat orci id tempor" )
declare -A e_parg_def=( [format]="ARG_EEEEE"      [name]="e" [type]="i" [range]="10:100"                [help]="Cras nec turpis at lorem ornare lacinia elementum in lacus. Aenean eget nulla purus. Nullam ultricies hendrerit volutpat" )
declare -A e_parg_def=( [format]="ARG_F..."       [name]="f" [type]="s" [default]="def"                 [help]="Cras nec turpis at lorem ornare lacinia elementum in lacus. Aenean eget nulla purus. Nullam ultricies hendrerit volutpat" )
# UBAD list for options
declare -a pargs_def=(
    $(declare -A | grep -oE -- " [[:alnum:]]*_parg_def")
)

# Parsed positional arguments (out)
declare -A pargs
# Parsed positional arguments (out)
declare -a parsed

# ============================================================== Envs ============================================================== #

# Envs' definitions
declare -A a_env_def=( [format]="ENV_A" [name]="a" [type]="p" [default]="some default" [help]="some description of a some description of a some description of a some description of a some description of a some description of a" )
declare -A b_env_def=( [format]="ENV_B" [name]="b" [type]="f"                          [help]="some description of b some description of b some description of b some description of b some description of b some description of b" )
# UBAD list for envs
declare -a envs_def=(
    $(declare -A | grep -oE -- " [[:alnum:]]*_env_def")
)

# Parse envs
declare -A envs

# ========================================================== Parse matter ========================================================== #

# Set envs
declare ENV_A="Some"
declare ENV_B="1"

# Parser's options
declare -a options
options+=( --with-help )
options+=( --verbose )

# Arguments
declare -a args_to_parse
# args_to_parse+=( --help ) # Add to print help
args_to_parse+=( -a )
args_to_parse+=( -b )
args_to_parse+=( --opt-d=var3 )
args_to_parse+=( --opt-e=11 )
args_to_parse+=( parg1 )
args_to_parse+=( parg2 )
args_to_parse+=( parg3 )
args_to_parse+=( parg4 )
args_to_parse+=( 55555 )
args_to_parse+=( parg6 )


# ============================================================= Parsing ============================================================ #

ARGUMENTS_DESCRIPTION_INTEND=5          \
ARGUMENTS_DESCRIPTION_LENGTH_MAX=120    \
parseargs ${options[@]}                 \
    --with-description  "$description"  \
    --with-cmd-name     "$cmd_name"     \
    --pargs-definitions pargs_def       \
    --opts-definitions  opts_def        \
    --envs-definitions  envs_def        \
    --pargs             pargs           \
    --opts              opts            \
    --envs              envs            \
-- args_to_parse parsed

declare ret=$?

# ============================================================= Results ============================================================ #

# If no help has been written
if [[ $ret != "5" ]]; then

    echo "Result: $ret"
    echo "========================= Options ========================="
    print_hash_array -n opts
    echo "========================== Envs ==========================="
    print_hash_array -n envs
    echo "========================== Pargs =========================="
    print_hash_array -n pargs
    echo "=========================== Info =========================="
    echo "Number of variadic arguments parsed: $(get_variadic_args_num pargs_def pargs)"

fi
