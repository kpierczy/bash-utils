#!/usr/bin/parg bash
# ====================================================================================================================================
# @file     parsepargs.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 21st February 2022 6:20:31 pm
# @modified Tuesday, 22nd February 2022 2:55:27 am
# @project  bash-utils
# @brief
#    
#    Set of functions used to implement 'parsepargs'
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================= Helpers ============================================================ #

# ---------------------------------------------------------------------------------------
# @brief Based on the definitions finds format of the positional argument corresponding
#    to the name @p parg_name in the UBAD table
#
# @params pargs_defs
#    list of valid options' definitions
# @param parg_name
#    name of the option to be matched
#
# @returns 
#    @retval @c 0 on success
#    @retval @c 1 if name does not correspond to any UBAd table on the list
# ---------------------------------------------------------------------------------------
function get_parg_format() {

    # Arguments
    local -n __get_parg_format_defs_="$1"
    local  __get_parg_format_name_="$2"

    local parg_def=""

    # Search a list of definitions to find name(s) corresponding to the given key
    for parg_def_idx in "${!__get_parg_format_defs_[@]}"; do

        # Get reference to the UBAD table
        local -n parg_def_ref="${__get_parg_format_defs_[$parg_def_idx]}"

        # If requred table has been found, break
        if [[ "${opt_def_ref[name]}" == "$__get_parg_format_name_" ]]; then

            # If format is defined for the argument, return it
            if is_var_set opt_def_ref[format]; then
                echo "${opt_def_ref[format]}"
                return 0
            # Else, auto-generate format of the argument based on the index
            else
                echo "ARG${parg_def_idx}"
                return 0
            fi
        fi

    done

    # If no option found, return error
    return 1
}

# ---------------------------------------------------------------------------------------
# @brief Based on the format of the positional arguments returns arity of the argument
#
# @params format
#    list of valid options' definitions
#
# @returns 
#    @retval @c 0 if a valid format has been given
#    @retval @c 1 otherwise
#
# @outputs 
#    arity of the argument in format:
#       - 1     : for single arguments (e.g. 'identifier')
#       - [num] : for multiple arguments (e.g. 'identifier[2]')
#       - ...   : variadic arguments (e.g. 'identifier...')
# ---------------------------------------------------------------------------------------
function get_parg_arity() {

    # Parse arguments
    local __get_parg_arity_format_="$1"

    # Variadic arguments
    if ends_with "$__get_parg_arity_format_" '...'; then
    
        echo "..."
        return 0

    # Multiple arguments 
    elif [[ "$__get_parg_arity_format_" =~ [[:alpha:]]*([[:alnum:]_])\[*([[:digit:]])\] ]]; then

        # Get arity
        local arity="${BASH_REMATCH[2]}"
        # Check if arity is positive
        if (( $arity < 0 )); then
            return 1
        fi

        echo "[$arity]"
        return 0

    # Single arguments 
    elif [[ "$__get_parg_arity_format_" =~ [[:alpha:]]*([[:alnum:]_])$ ]]; then

        echo "1"
        return 0

    # Invalid format
    else
        return 1
    fi

}

# ========================================================= Implementations ======================================================== #

# ---------------------------------------------------------------------------------------
# @brief Parses parg arguments
#
# @param args
#    name of the list of arguments to be parsed
# @param pargs_defs
#    name of the UBAD list containing pargs' definitions
# @param flag_def_type
#    verbosity mode (either 'defined' or 'undefined')
# @param pargs_types [out]
#    name of the hash array holding pairs pargname-pargtype (every name has it's type
#    defined here)
# @param pargs [out]
#    name of the hash array holding values of actually parsed pargs (pargs's whose
#    names have no defined value inside this array has not been parsed)
#
# @returns 
#    @retval @c 0 on success 
#    @retval @c 1 if function sufferred from the bug 
#    @retval @c 2 if invalid option has been passed 
#    @retval @c 4 if invalid UBAD list has been given
#
# @note Types of arguments are not being checke dby the function. They are assumed
#    to be checked by the calling function (i.e. `parseargs`)
# ---------------------------------------------------------------------------------------
function parsepargs_parse_pargs() {

    # Parse arguments
    local -n __parsepargs_parse_pargs_args_="$1"
    local    __parsepargs_parse_pargs_pargs_defs_="$2"
    local    __parsepargs_parse_pargs_flag_def_type_="$3"
    local -n __parsepargs_parse_pargs_pargs_types_="$4"
    local -n __parsepargs_parse_pargs_pargs_="$5"

    # ------------------------------ Parse pargs ------------------------------

    # Initialize number of parsed positional arguments parsed
    local args_parsed_num=0

    # Get reference to the UBAD list
    local -n __parsepargs_parse_pargs_pargs_defs_ref_="$__parsepargs_parse_pargs_pargs_defs_"

    local __parsepargs_parse_pargs_parg_def_idx_

    # Iterate over indeces of the UBAD list
    for __parsepargs_parse_pargs_parg_def_idx_ in "${!__parsepargs_parse_pargs_pargs_defs_ref_[@]}"; do

        # Get reference to the UBAD table of the given parg
        local -n __parsepargs_parse_pargs_parg_def_ref_="${__parsepargs_parse_pargs_pargs_defs_ref_[$__parsepargs_parse_pargs_parg_def_idx_]}"
        
        # Get name of the parg
        local name="${__parsepargs_parse_pargs_parg_def_ref_[name]}"
        # Get type of the parg
        local type="string"
        if is_var_set __parsepargs_parse_pargs_parg_def_ref_[type]; then
            type="${__parsepargs_parse_pargs_parg_def_ref_[type]}"
        fi
        # Get arity of the parg (if format is no defined, it will result in arity @c 1)
        local arity=$(get_parg_arity "${__parsepargs_parse_pargs_parg_def_ref_[format]}")

        # ---------------------------- Single arguments ---------------------------

        # If single argument has been parsed
        if [[ "$arity" == "1" ]]; then

            # Keep it's type
            __parsepargs_parse_pargs_pargs_types_["$name"]="$type"

            local arg

            # If argument was given, just parse it
            if is_var_set __parsepargs_parse_pargs_args_["$args_parsed_num"]; then

                arg="${__parsepargs_parse_pargs_args_[$args_parsed_num]}"

            # Else, check if argument has a default value
            elif is_var_set __parsepargs_parse_pargs_parg_def_ref_[default]; then
                
                arg="${__parsepargs_parse_pargs_parg_def_ref_[default]}"

            # If argument was NOT given, report error
            else

                # Parse format of the argument
                local format="ARG$(($args_parsed_num + 1))"
                if is_var_set __parsepargs_parse_pargs_parg_def_ref_[format]; then
                    format="${__parsepargs_parse_pargs_parg_def_ref_[format]}"
                fi
                
                log_error "Required argument '$format' has not been given"
                return 1

            fi

            
            # If parg is a flag argument, perform special parsing
            if is_ubad_arg_flag "${__parsepargs_parse_pargs_pargs_types_[$name]}"; then

                # Parse flag only if it is set to '1'
                if [[ "$arg" == "1" ]]; then
                    __parsepargs_parse_pargs_pargs_["$name"]="0"
                # Else, if 'unpresent flags define' option is set, define option as unparsed
                elif [[ "${__parsepargs_parse_pargs_flag_def_type_}" == "defined" ]]; then
                    __parsepargs_parse_pargs_pargs_["$name"]="1"
                fi

            # For other types, just parse value of the parg
            else
                __parsepargs_parse_pargs_pargs_["$name"]="$arg"
            fi

            # Increment number of parsed arguments
            ((args_parsed_num = $args_parsed_num + 1))
            
        # --------------------------- Multiple arguments --------------------------

        # If multiple argument has been parsed
        elif [[ "$arity" == \[*\] ]]; then

            # Get number of arguments in the pack (remov '[' and ']' from both sides)
            local pack_size="${arity:1:-1}"
            
            # Iterate over pack and parse corresponding arguments
            for ((i = 0; i < $pack_size; i++)); do

                # Compose name of the argument
                local pack_elem_name="$name$(($i + 1))"
                
                # Keep it's type
                __parsepargs_parse_pargs_pargs_types_["$pack_elem_name"]="$type"

                local arg

                # If argument was given, just parse it
                if is_var_set __parsepargs_parse_pargs_args_["$args_parsed_num"]; then

                    arg="${__parsepargs_parse_pargs_args_[$args_parsed_num]}"

                # Else, check if argument has a default value
                elif is_var_set __parsepargs_parse_pargs_parg_def_ref_[default]; then

                    arg="${__parsepargs_parse_pargs_parg_def_ref_[default]}"

                # If argument was NOT given, report error
                else

                    # Parse format of the argument
                    local format="ARG$(($args_parsed_num + 1))"
                    if is_var_set __parsepargs_parse_pargs_parg_def_ref_[format]; then
                        format="${__parsepargs_parse_pargs_parg_def_ref_[format]}" # Get format
                        format="${format%$arity}"                                  # Remove arity form the format's end
                        format="${format}$(($i + 1))"                              # Add idnex of the argument in the pack
                    fi
                    
                    log_error "Required argument '$format' has not been given"
                    return 1

                fi
                
                # If parg is a flag argument, perform special parsing
                if is_ubad_arg_flag "${__parsepargs_parse_pargs_pargs_types_[$pack_elem_name]}"; then

                    # Parse flag only if it is set to '1'
                    if [[ "$arg" == "1" ]]; then
                        __parsepargs_parse_pargs_pargs_["$pack_elem_name"]="0"
                    # Else, if 'unpresent flags define' option is set, define option as unparsed
                    elif [[ "${__parsepargs_parse_pargs_flag_def_type_}" == "defined" ]]; then
                        __parsepargs_parse_pargs_pargs_["$pack_elem_name"]="1"
                    fi

                # For other types, just parse value of the parg
                else
                    __parsepargs_parse_pargs_pargs_["$pack_elem_name"]="$arg"
                fi

                # Increment number of parsed arguments
                ((args_parsed_num = $args_parsed_num + 1))

            done

        # --------------------------- Variadic arguments --------------------------

        # If variadic argument has been parsed
        elif [[ "$arity" == "..." ]]; then

            # Get number of argument left to be parsed as variadic
            local args_left_num=$(( ${#__parsepargs_parse_pargs_args_[@]} - $args_parsed_num ))

            # If no arguments left
            if (( $args_left_num < 1 )); then

                # Check if default value has been given
                if is_var_set __parsepargs_parse_pargs_parg_def_ref_[default]; then

                    # Keep it's type
                    __parsepargs_parse_pargs_pargs_types_["$name"]="$type"
                    # Parse value as default
                    __parsepargs_parse_pargs_pargs_["$name"]="${__parsepargs_parse_pargs_parg_def_ref_[default]}"

                fi

            # If some arguments left, parse them
            else

                # Iterate over variadic arguments
                for ((i = 0; i < $args_left_num; i++)); do

                    # Compose name of the argument
                    local vpack_elem_name="$name$(($i + 1))"

                    # Keep it's type
                    __parsepargs_parse_pargs_pargs_types_["$vpack_elem_name"]="$type"

                    # Parse argument
                    local arg="${__parsepargs_parse_pargs_args_[$args_parsed_num]}"

                    # If parg is a flag argument, perform special parsing
                    if is_ubad_arg_flag "${__parsepargs_parse_pargs_pargs_types_[$vpack_elem_name]}"; then

                        # Parse flag only if it is set to '1'
                        if [[ "$arg" == "1" ]]; then
                            __parsepargs_parse_pargs_pargs_["$vpack_elem_name"]="0"
                        # Else, if 'unpresent flags define' option is set, define option as unparsed
                        elif [[ "${__parsepargs_parse_pargs_flag_def_type_}" == "defined" ]]; then
                            __parsepargs_parse_pargs_pargs_["$vpack_elem_name"]="1"
                        fi

                    # For other types, just parse value of the parg
                    else
                        __parsepargs_parse_pargs_pargs_["$vpack_elem_name"]="$arg"
                    fi

                    # Increment number of parsed arguments
                    ((args_parsed_num = $args_parsed_num + 1))

                done

            fi

            # Finish parsing
            break

        # -------------------------------------------------------------------------

        # If invalid argument format has been parsed
        else
            log_error "Invalid format of the '$name' positional argument has been given (${__parsepargs_parse_pargs_parg_def_ref_[format]})"
            return 4
        fi

    done

    # -------------------------------------------------------------------------

    return 0
}

# ========================================================= Help formatter ========================================================= #

# ---------------------------------------------------------------------------------------
# @brief: Generates list of named paositional parameters based on the UBAD list
#
# @param defs
#     name of the UBAD list to be inspected
#
# @outputs
#    compiled string
# ---------------------------------------------------------------------------------------
function parsepargs_generate_required_arguments() {

    # Parse arguments
    local __parsepargs_generate_required_arguments_defs_="$1"

    # Get reference to the UBAD list
    local -n __parsepargs_generate_required_arguments_defs_ref_="$__parsepargs_generate_required_arguments_defs_"
    # Initialize result string
    local __parsepargs_generate_required_arguments_result_=""
    # Initialize arguments' index counter
    local __parsepargs_generate_required_arguments_index_count_=1

    local __parsepargs_generate_required_arguments_def_

    # Iterate over UBAD list
    for __parsepargs_generate_required_arguments_def_ in "${__parsepargs_generate_required_arguments_defs_ref_[@]}"; do

        # Get reference to the UBAD table
        local -n __parsepargs_generate_required_arguments_def_ref_="$__parsepargs_generate_required_arguments_def_"

        # If table describes variadic argument, append string based on the format
        if is_var_set __parsepargs_generate_required_arguments_def_ref_[format]; then
            
            # Get the format
            local format="${__parsepargs_generate_required_arguments_def_ref_[format]}"
            # Get the arity
            local arity="$(get_parg_arity $format)"
            # Append string based on the format
            if [[ "$arity" == "1" ]]; then

                # Append basic string based on the format
                __parsepargs_generate_required_arguments_result_+=$(is_var_set __parsepargs_generate_required_arguments_def_ref_[default] \
                    && echo "[$format] " || echo "$format ")
                # Increment arguments' index counter
                ((__parsepargs_generate_required_arguments_index_count_ = $__parsepargs_generate_required_arguments_index_count_ + 1 ))

            elif [[ "$arity" == \[*\] ]]; then

                # Append basic string based on the format
                __parsepargs_generate_required_arguments_result_+=$(is_var_set __parsepargs_generate_required_arguments_def_ref_[default] \
                    && echo "[$format] " || echo "$format ")
                # Increment arguments' index counter
                ((__parsepargs_generate_required_arguments_index_count_ = $__parsepargs_generate_required_arguments_index_count_ + ${arity:1:-1} ))
                
            elif [[ "$arity" == '...' ]]; then

                # Append basic string based on the format
                __parsepargs_generate_required_arguments_result_+=$(is_var_set __parsepargs_generate_required_arguments_def_ref_[default] \
                    && echo "[$format] " || echo "$format ")
                # End compilation
                break                

            fi
            
        # Else, if format is not defined
        else

            # Append basic string based on the index
            __parsepargs_generate_required_arguments_result_+="ARG${__parsepargs_generate_required_arguments_index_count_} "
            # Increment arguments' index counter
            ((__parsepargs_generate_required_arguments_index_count_ = $__parsepargs_generate_required_arguments_index_count_ + 1 ))

        fi

    done

    # Remove trailing space
    __parsepargs_generate_required_arguments_result_="${__parsepargs_generate_required_arguments_result_::-1}"
    # Output result
    echo "$__parsepargs_generate_required_arguments_result_"
    
}


# ---------------------------------------------------------------------------------------
# @brief Automatically generates description of pargs arguments based on the UBAD list
#
# @param pargs_defs
#    name of the UBAD list containing pargs arguments' definitions
# @param parse_mode ( optional, default: 'default' )
#    parse mode (either 'default' - list element's will be trimmed - or 'raw' - list 
#    element's will NOT be trimmed)
# ---------------------------------------------------------------------------------------
function generate_pargs_description() {   

    # Parse arguments
    local __generate_pargs_description_opt_pargs_="$1"
    
    local __generate_pargs_description_parse_mode_="${2:-default}"

    # ------------------------ Format the description -------------------------
    
    # Prepare outpt hash array for formats
    local -A formats=()
    # Prepare outpt hash array for helps
    local -A helps=()
    # Prepare outpt hash array for types
    local -A types=()
    
    local opt_def=""

    # Parse formats and helps
    parse_description_info                          \
        "$__generate_pargs_description_opt_pargs_"  \
        "$__generate_pargs_description_parse_mode_" \
        formats helps types

    # Compile description text
    compile_description_info formats helps

    # -------------------------------------------------------------------------
}

# ================================================================================================================================== #
