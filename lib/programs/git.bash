# ====================================================================================================================================
# @file     git.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Monday, 29th November 2021 2:07:06 pm
# @modified Thursday, 17th February 2022 11:59:25 am
# @project  Winder
# @brief
#    
#    Set of handy script functions related to git
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# ---------------------------------------------------------------------------------------
# @brief Downloads git repositories listed in array names @p list
#
# @param list
#    name of the array holding list of names of hash arrays describing git 
#    repositories to be downloaded each hash array shall contain following keys:
#
#         'url'  - URL of the repository
#         'path' - destination of the downloaded repository (optional, default: .)
#         'tag'  - name of the tag/branch to be downloaded (optional)
# 
# @returns 
#    @retval @c 0 on success
#    @retval @c 0 on error
#
# @options
#
#     -v|--verbose  prints verbose logs when installing
#               -p  skips downloading when given 'path' already exists
#
# @environment
#
#     GIT_FLAGS  optional name of the array containing additional flags to be passed
#                to the call to git clone
#
# ---------------------------------------------------------------------------------------
function git_clone_list() {

    # Arguments
    local list=""

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-v|--verbose',verbose,f
        '-p',skip_existing,f
    )
    
    # Parse arguments to a named array
    parse_options_s

    # Get source directory
    local -n list="${posargs[0]}"

    # ----------------- Configure logs ----------------  

    # Keep current configuration of logs on the stack
    push_stack $(get_stdout_logs_status)

    # Enable/disable logs depending on the configuration
    is_var_set options[verbose] && 
        enable_stdout_logs || 
        disable_stdout_logs

    # -------------- Download repositories ------------  

    local repo_descriptor_name

    # Iterate over repositories' descriptors
    for repo_descriptor_name in "${list[@]}"; do

        # Check if element is a hash array
        is_hash_array "$repo_descriptor_name" || {
            log_error "$repo_descriptor_name is not a descriptor of the repository"
            restore_log_config_from_default_stack
            return 1
        }

        # Get reference to the descriptor
        local -n repo_descriptor="$repo_descriptor_name"
        
        # Check if hash array is a valid repository descriptor
        is_var_set_non_empty repo_descriptor[url] ||  {
            log_error "$repo_descriptor_name is not a descriptor of the repository"
            restore_log_config_from_default_stack
            return 1
        }
        
        # If no path given, set default path
        is_var_set_non_empty repo_descriptor[path] ||
            repo_descriptor[path]="."

        # Check if repository already downloaded if requested
        if is_var_set_non_empty options[skip_existing] && [[ -d "${repo_descriptor[path]}" ]]; then
            continue
        fi

        log_info "Downloading ${repo_descriptor[url]} repository ..."

        # If tag given, prepare branch flag
        local git_branch=''
        is_var_set_non_empty repo_descriptor[tag] &&
            git_branch="--branch=${repo_descriptor[tag]}"
        # Prepare custom flags if given
        local -a no_flags=()
        local -n custom_flags=${GIT_FLAGS:-no_flags}

        # Create destination directory if required
        mkdir -p $(realpath $(dirname ${repo_descriptor[path]}))

        # Download repository
        git clone \
            "${custom_flags[@]}" \
            "${git_branch}" \
            "${repo_descriptor[url]}" \
            "${repo_descriptor[path]}" ||
        {
            log_error "Failed to download ${repo_descriptor[url]} repository"
            restore_log_config_from_default_stack
            return 1
        }

        log_info "Repository downloaded"

    done

    # -------------------------------------------------  

    # Restore logs settings
    restore_log_config_from_default_stack
}
