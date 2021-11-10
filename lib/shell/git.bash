# ====================================================================================================================================
# @file     git.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 26th October 2021 12:39:47 pm
# @modified Tuesday, 9th November 2021 7:22:13 pm
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
gitaddm() { 

    # Options 
    local defs=(
        '-b',branch
    )

    # Enable words-splitting locally
    local IFS
    enable_word_splitting

    # Parse options
    local -A options
    parseopts "$*" defs options posargs

    # Arguments
    local url="${posargs[0]}"
    local path="${posargs[1]}"

    # If @var PROJECT_HOME set, jump to repo's root
    is_var_set PROJECT_HOME && pushd $PROJECT_HOME

    # Prepare (optional) branch flag
    if is_var_set options[branch]; then
        local git_opts="-b ${options[branch]}"
    else
        local git_opts=''
    fi

    # Add submodule
    echo "CMD: git submodule add $git_opts $url $path"
    git submodule add $git_opts $url $path
    
    # If @var PROJECT_HOME set, back to initial directory
    is_var_set PROJECT_HOME && popd
}


# -------------------------------------------------------------------
# @brief Git add module with the specified branch
# @param repository
#    respository to be submoduled
# @param branch
#    branch to be submoduled
# @param path
#    local path to the submoduled repository (relative to 
#    project's home directory)
# -------------------------------------------------------------------
gitaddmb() { 
    PWD=`pwd`
    cd $PROJECT_HOME
    git submodule add -b $2 $1 $3
    cd $PWD
}

# -------------------------------------------------------------------
# @brief Removes git submodule from the project
# @param path
#    local path to the submoduled repository (relative to 
#    project's home directory)
# -------------------------------------------------------------------
gitrmm() {
    PWD=`pwd`
    cd $PROJECT_HOME
    mv $1 $1_tmp
    git submodule deinit -f -- $1
    rm -rf .git/modules/$1
    git rm -f $1
    rm -rf $1 $1_tmp
    cd $PWD
}
