#!/usr/bin/env bash
# ====================================================================================================================================
# @file     python.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 4:29:08 pm
# @modified Saturday, 6th November 2021 4:53:52 pm
# @project  BashUtils
# @brief
#    
#    Installs the given version of the Python
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

get_heredoc usage <<END
    Description: Installs requested python version and sets ubuntu alternatives
    Usage: python.bash CMD VERSION

    Arguments:

        CMD  command to be executed

                        install  installs requested python version
                set-alternative  sets python alternative to the requested version
                                 (if version is not installed, installs)

    Options:
      
        --help  displays this usage message

    Environment:

        ALTNAME  name of the alternative to be set (set-alternative variant);
                 optional [default: python]

END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="python"

# ============================================================ Functions =========================================================== #

set_python_alternative() {

    # Check if python version is already installed
    which $target > /dev/null || install_python
    
    # Get alternative's name to be set
    local altname=${ALTNAME:-python}

    # Set alternative
    local args=''
    args+="/usr/bin/$altname"        # Symlink to be created
    args+="python"                 # Name of the alternative
    args+="/usr/local/bin/$target" # Path to the installed version
    args+="1"                      # Priority

    # Set alternative
    sudo update-alternatives --install $args
    
}

install_python() {

    # Python package repository
    local PYTHON_REPO="ppa:deadsnakes/ppa"

    # Get repositories added to the apt
    local repos=$(find /etc/apt/ -name *.list | xargs cat | grep  ^[[:space:]]*deb)

    # Add deadsnakes repository to apt
    echo $repos | grep ${PYTHON_REPO#ppa:} > /dev/null || sudo add-apt-repository $PYTHON_REPO

    logc_info "Installing $target ..."

    # Install version
    sudo apt install -y $target || {
        logc_error "Could not install $target"
        return 1
    }

    logc_info "${target^} installed"

}

# ============================================================== Main ============================================================== #

main() {

    # Arguments
    local cmd
    local version

    # ---------------------------------- Configuration ----------------------------------

    # Requirewd number of arguments
    local ARG_NUM=2

    # Commands
    local COMMANDS=(
        install
        set-alternative
    )

    # Options
    local defs=(
        '--help',help,f
    )

    # Dependencies
    local dependencies=(
        software-properties-common
    )

    # ------------------------------------ Processing -----------------------------------

    # Parsed options
    parse_argumants

    # Parse argument
    cmd=${1:-}
    version=${2:-}

    # Validate argument
    is_one_of $cmd COMMANDS      &&
    is_var_set_non_empty version || 
    {
        logc_error "Invalid usage"
        echo $usage
        return 1
    }

    # Install dependencies
    install_packages --su -y -v -U dependencies || {
        logc_error "Could not install required dependencies"
        return 1
    }

    # Define command target
    target=python$version
    
    # Perform corresponding routine
    case $cmd in
        install        ) set_python_alternative;;
        set-alternative) install_python;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

