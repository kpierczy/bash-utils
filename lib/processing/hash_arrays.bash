#!/usr/bin/env bash
# ====================================================================================================================================
# @file     hash_arrays.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 2:36:24 pm
# @modified Friday, 25th February 2022 1:17:15 am
# @project  bash-utils
# @brief
#    
#    Set of tools related to bash hash arrays
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Prints array with name passed as @p arr argument
#
# @param arr
#    name fo the array to be printed
#
# @options
#
#    -n|--name  if given, name of the array is printed
#
# -------------------------------------------------------------------
function print_hash_array() {

    # Arguments
    local -n __print_hash_array_arr_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a __print_hash_array_opt_definitions_=(
        '-n|--name',name,f
    )
    
    # Parse arguments to a named array
    local -a __print_hash_array_args_=( "$@" )

    # Prepare names hash arrays for positional arguments and parsed options
    local -a __print_hash_array_posargs_=()
    local -A __print_hash_array_options_=()

    # Parse options
    parseopts_s                             \
        __print_hash_array_args_            \
        __print_hash_array_opt_definitions_ \
        __print_hash_array_options_         \
        __print_hash_array_posargs_         \
    || return 1

    # Parse arguments
    __print_hash_array_arr_="${__print_hash_array_posargs_[0]}"

    # ------------------------------------------------- 

    # Print name of the array
    is_var_set __print_hash_array_options_[name] && echo "${__print_hash_array_posargs_[0]}:"
    
    local __print_hash_array_key_

    # Print array
    for __print_hash_array_key_ in "${!__print_hash_array_arr_[@]}"; do 
        printf "[%s]=%s\n" "$__print_hash_array_key_" "${__print_hash_array_arr_[$__print_hash_array_key_]}"
    done

}

# -------------------------------------------------------------------
# @brief Prints string defining an hash array with the given name
#
# @param array
#    name fo the array to be printed
# @options
#    -l|--local if set, definition will be printed with `local`
#               keyword ; otherwise, the `declare` keyword will be
#               used
# -------------------------------------------------------------------
function print_hash_array_def() {

    # Arguments
    local array_name

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-l|--local',local,f
        '-s|--separator',separator
    )
    
    # Parse arguments to a named array
    local -a args=( "$@" )

    # Prepare names hash arrays for positional arguments and parsed options
    local -a posargs=()
    local -A options=()

    # Parse options
    parseopts_s         \
        args            \
        opt_definitions \
        options         \
        posargs         \
    || return 1
    
    # Parse arguments
    local array_name="${posargs[0]}"
    
    # ------------------------------------------------- 

    local result=""

    # Get refernce to the array 
    local -n array="$array_name"

    # Print name of the array
    is_var_set opts[local] &&
        result+="local   -A $array_name=" ||
        result+="declare -A $array_name="
    
    # Open bracket
    result+="( "
    
    local key

    # Print array
    for key in "${!array[@]}"; do 
        result+="[$key]=\"${array[$key]}\" "
    done

    # Close bracket
    result+=");"

    # Print result
    echo "$result"
}

# -------------------------------------------------------------------
# @brief Checks whether hash array named @p harray has a field named
#    @p field defined
#
# @param harray
#    name fo the hash array to be verified
# @param field
#    field of the @p harray to be checked
#
# @returns
#    @retval @c 0 if @p harray has a field names @p field
#    @retval @c 1 otherwise
#    @retval @c 2 if @p harray is not a hash array
# -------------------------------------------------------------------
function has_hash_array_field() {

    # Parse arguments
    local harray_="$1"
    local field_="$2"

    # Check if @p harray is a hash_array
    is_hash_array $harray_ || return 2

    # Get reference to the array
    local -n harray_ref="$harray_"
    # Check if @p field is defined
    [ ${harray_ref[$field_]+x} ] || return 1

    return 0
}

# -------------------------------------------------------------------
# @brief Copies contenty of @p src hash array into the @p dst hash
#    array
#
# @param src
#    name of the source hash array
# @param dst
#    name of the destination hash array
#
# @returns
#    @retval @c 0 on success
#    @retval @c 1 if @p src or @dst is not a hash array
# -------------------------------------------------------------------
function copy_hash_array() {

    # Parse arguments
    local src_="$1"
    local dst_="$2"

    # Check if @p harray is a hash_array
    is_hash_array $src_ && is_hash_array $dst_ || return 1

    # Parse arguments
    local -n src_ref_="$src_"
    local -n dst_ref_="$dst_"

    # Reset destination
    dst_ref_=()
    # Copy content
    for key in "${!src_ref_[@]}"; do 
        dst_ref_["$key"]="${src_ref_[$key]}"
    done

    return 0
}