#!/usr/bin/env bash
# ====================================================================================================================================
# @file     env_stack.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 23rd February 2022 8:04:01 pm
# @modified Friday, 25th February 2022 9:09:11 am
# @project  bash-utils
# @brief
#    
#    Set of functions enabling creating, storing and restoring of stacks holding environmental variables
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Removes all environmental variables exept of these for those @p predicate
#    returns @false
#
# @param predicate ( optional, default: keeps nothing )
#    predicate stating whether variable should be unset
# ---------------------------------------------------------------------------------------
function clean_env () {

    # Arguments
    local predicate="${1:-}"

    # Check if `nounset` option is set
    is_shell_option_set 'nounset'
    local nounset_set="$?"
    # Treat unsets as error
    set +o nounset

    # Enable word splitting
    localize_word_splitting
    enable_word_splitting

    # Get list of variables
    local var_list=( $(export | grep "^declare -x" | sed -e "s/declare -x //" | cut -d"=" -f1 | grep -E '[[:upper:]]+\b') )

    local var

    # Iterate over vriable and unset if predicate given
    if is_var_set predicate; then
        for var in ${var_list[@]} ; do
            if $predicate "$var"; then
                unset "$var"
            fi
        done
    # Otherwise, keep nothing
    else
        for var in ${var_list[@]} ; do
            unset "$var"
        done
    fi

    # If `nounset` was set, set it again
    if [[ "$nounset_set" == "0" ]]; then
        set -o nounset
    fi
}

# ---------------------------------------------------------------------------------------
# @brief Start a new stack level to save variables. Must call this before saving any 
#     variables
# ---------------------------------------------------------------------------------------
function clear_env_stack () {

    # Check if `nounset` option is set
    is_shell_option_set 'nounset'
    local nounset_set="$?"
    # Treat unsets as error
    set +o nounset
    
    # Force expr return 0 to avoid script fail
    ENV_STACK_LEVEL=`expr $ENV_STACK_LEVEL \+ 1 || true`
    # Initialize stack list
    eval ENV_STACK_LIST_$ENV_STACK_LEVEL=
    
    # If `nounset` was set, set it again
    if [[ "$nounset_set" == "0" ]]; then
        set -o nounset
    fi

}

# ---------------------------------------------------------------------------------------
# @brief Save a variable to current stack level, and set new value to this var.
#    If a variable has been saved, won't save it. Just set new value.
#
# @param name
#    name of the variable to be stored
# @param new_value
#    new value of the @p name variable
#
# @returns
#    @retval @c 0 on success
#    @retval @c 1 when ENV_STACK_LEVEL <= 0
# ---------------------------------------------------------------------------------------
function push_env_stack () {

    local _name="$1"
    local _new_val="$2"

    # Check if `nounset` option is set
    is_shell_option_set 'nounset'
    local nounset_set="$?"
    # Treat unsets as error
    set +o nounset
    
    # If stack level is not positive, return error
    if [[ "$ENV_STACK_LEVEL" -le 0 ]]; then

        # If `nounset` was set, set it again
        if [[ "$nounset_set" == "0" ]]; then
            set -o nounset
        fi
        # Return error
        return 1
        
    fi

    # Enable automatic word splitting in case it is diabled
    localize_word_splitting
    enable_word_splitting

    # Get current value of the variable
    eval local _oldval=\"\${$_name}\"
    # Check if value is saved on the stack
    eval local _saved=\"\${ENV_STACK_LEVEL_SAVED_${ENV_STACK_LEVEL}_${_name}}\"

    # If value not saved, save it
    if [ "x$_saved" = "x" ]; then
    
        # Get current stack
        eval local _temp=\"\${ENV_STACK_LIST_$ENV_STACK_LEVEL}\"
        # Save stack with a new variable name on it
        eval ENV_STACK_LIST_$ENV_STACK_LEVEL=\"$_name $_temp\"
        # Save value of the variable encoded with current level and variable's name
        eval ENV_STACK_SAVE_LEVEL_${ENV_STACK_LEVEL}_$_name=\"$_oldval\"

        # Mark variable as saved
        eval ENV_STACK_LEVEL_SAVED_${ENV_STACK_LEVEL}_$_name="yes"
        # Mark variable as 'set' if in fact it's set
        eval ENV_STACK_LEVEL_PRESET_${ENV_STACK_LEVEL}_$_name=\"\${$_name+set}\"

    fi

    # Assign a new value to the variable
    eval export $_name=\"$_new_val\"

    # If `nounset` was set, set it again
    if [[ "$nounset_set" == "0" ]]; then
        set -o nounset
    fi

}


# ---------------------------------------------------------------------------------------
# @brief Restore all variables that have been saved in current stack level
#
# @returns
#    @retval @c 0 on success
#    @retval @c 1 when ENV_STACK_LEVEL <= 0
# ---------------------------------------------------------------------------------------
function restore_env_stack () {

    # Check if `nounset` option is set
    is_shell_option_set 'nounset'
    local nounset_set="$?"
    # Treat unsets as error
    set +o nounset

    # If stack level is not positive, return error (cannot restore an empty stack)
    if [[ "$ENV_STACK_LEVEL" -le 0 ]]; then

        # If `nounset` was set, set it again
        if [[ "$nounset_set" == "0" ]]; then
            set -o nounset
        fi
        # Return error
        return 1
        
    fi

    # Enable automatic word splitting in case it is diabled
    localize_word_splitting
    enable_word_splitting

    # Get current stack
    eval local _list=\"\${ENV_STACK_LIST_$ENV_STACK_LEVEL}\"
    
    local _varname

    # Iterate over names saved on stack
    for _varname in $_list; do

        # Check whether value has been actually set
        eval local _varname_preset=\"\${ENV_STACK_LEVEL_PRESET_${ENV_STACK_LEVEL}_${_varname}}\"
        
        # If set, assign it's value to the saved name
        if [ "x$_varname_preset" = "xset" ] ; then
            eval $_varname=\"\${ENV_STACK_SAVE_LEVEL_${ENV_STACK_LEVEL}_$_varname}\"
        # Otherwise, unset variable
        else
            unset $_varname
        fi

        # Mark a variable as non-saved on the stack
        eval ENV_STACK_SAVE_LEVEL_${ENV_STACK_LEVEL}_$_varname=

    done
    
    # Force expr return 0 to avoid script fail
    ENV_STACK_LEVEL=`expr $ENV_STACK_LEVEL \- 1 || true`

    # If `nounset` was set, set it again
    if [[ "$nounset_set" == "0" ]]; then
        set -o nounset
    fi
}


# ---------------------------------------------------------------------------------------
# @brief Save a variable to current stack level, and sets it to the old value prepended
#    with @p value
#
# @param name
#    name of the variable to be stored
# @param value
#    value to be prepended
#
# @returns
#    @retval @c 0 on success
#    @retval @c 1 when ENV_STACK_LEVEL <= 0
# ---------------------------------------------------------------------------------------
function prepend_env_stack() {

    # Arguments
    local _name="$1"
    local _value="$2"

    # Check if `nounset` option is set
    is_shell_option_set 'nounset'
    local nounset_set="$?"
    # Treat unsets as error
    set +o nounset
    
    # Get current value of the variable
    eval local _oldval=\"\$$_name\"
    # Push value on the stack and assign it with old value prepended with @p value
    push_env_stack "$_name" "$_value$_oldval"

    # If `nounset` was set, set it again
    if [[ "$nounset_set" == "0" ]]; then
        set -o nounset
    fi
}

# ---------------------------------------------------------------------------------------
# @brief Save current @env PATH to current stack level, and sets it to the old value 
#    prepended with @p value
#
# @param value
#    value to be prepended
#
# @returns
#    @retval @c 0 on success
#    @retval @c 1 when ENV_STACK_LEVEL <= 0
# ---------------------------------------------------------------------------------------
function prepend_path_env_stack() {

    # Arguments
    local _value="$1"

    # Check if `nounset` option is set
    is_shell_option_set 'nounset'
    local nounset_set="$?"
    # Treat unsets as error
    set +o nounset
    
    # Get current path
    eval local old_path="\"\$PATH\""

    # If path is empty, assign only the new value
    if [ x"$old_path" == "x" ]; then
        prepend_env_stack "PATH" "$_value"
    # Otherwise prepend with the new value and a colon
    else
        prepend_env_stack "PATH" "$_value:"
    fi

    # If `nounset` was set, set it again
    if [[ "$nounset_set" == "0" ]]; then
        set -o nounset
    fi
}