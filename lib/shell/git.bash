# ====================================================================================================================================
# @file     git.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 26th October 2021 12:39:47 pm
# @modified Monday, 22nd November 2021 9:57:30 pm
# @project  BashUtils
# @brief
#    
#    Sourcing this script provides user's terminal with handy git-related commands
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Git add submodule
#
# @param url
#    respository to be submoduled
# @param path
#    local path to the submoduled repository
#
# @options
#
#    -b=branch branch to be submoduled
#
# @environment
#
#    @var PROJECT_HOME (path)
#       absolute path tot he git project's root (default: .)
#
# -------------------------------------------------------------------
function gitaddm() { 

    # Arguments
    local url_
    local path_

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-b',branch
    )
    
    # Parse arguments to a named array
    parse_options

    # Parse arguments
    local url_="${posargs[0]}"
    local path_="${posargs[1]}"

    # -------------------------------------------------

    # If @var PROJECT_HOME set, jump to repo's root
    is_var_set PROJECT_HOME && pushd $PROJECT_HOME

    # Prepare (optional) branch flag
    if is_var_set options[branch]; then
        local git_opts_="-b ${options[branch]}"
    else
        local git_opts_=''
    fi

    # Add submodule
    git submodule add $git_opts_ $url_ $path_
    
    # If @var PROJECT_HOME set, back to initial directory
    is_var_set PROJECT_HOME && popd
    
}

# -------------------------------------------------------------------
# @brief Removes git submodule from the project
#
# @param path
#    local path to the submoduled repository (relative to 
#    project's home directory)
#
# @environment
#
#    @var PROJECT_HOME (path)
#       absolute path tot he git project's root (default: .)
#
# -------------------------------------------------------------------
gitrmm() {

    # Arguments
    local path_="$1"

    # If @var PROJECT_HOME set, jump to repo's root
    is_var_set PROJECT_HOME && pushd $PROJECT_HOME

    # Change name of the submodule to the temporary one
    mv ${path_} ${path_}_tmp
    # Deinitialize the submodule in the git
    git submodule deinit -f -- ${path_}
    # Remove submodule's data from git's directory
    rm -rf .git/modules/${path_}
    # Remove submodule's folder from the repositories' tree
    git rm -f ${path_}
    # Remove files of the submodule
    rm -rf ${path_} ${path_}_tmp
    
    # If @var PROJECT_HOME set, back to initial directory
    is_var_set PROJECT_HOME && popd

}

# -------------------------------------------------------------------
# @brief Commits and pushes changes from the git submodule to the
#   module's repository (pushes to origin master)
#
# @param message
#    commit message
# @param path (optional, default: .)
#    local path to the submoduled repository (relative to 
#    project's home directory)
#
# @environment
#
#    @var PROJECT_HOME (path)
#       absolute path tot he git project's root (default: .)
#
# -------------------------------------------------------------------
git_push_submodule_changes_to_master() {

    # Arguments
    local message_="$1"
    local path_="${2:-.}"

    # If @var PROJECT_HOME set, jump to repo's root
    is_var_set PROJECT_HOME && pushd "$PROJECT_HOME"
    # Enter the submodule
    pushd "$path_"

    # Commit changes
    git commit -m "$message_"
    # Merge detached changes with master
    git branch tmp-branch
    git checkout master
    git merge tmp-branch
    # Push to master
    git push
    # Remove temporary branch
    git branch -d tmp-branch
    
    popd    
    # If @var PROJECT_HOME set, back to initial directory
    is_var_set PROJECT_HOME && popd

}
