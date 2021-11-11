#!/usr/bin/env bash
# ====================================================================================================================================
# @file     python.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 4:29:08 pm
# @modified Wednesday, 10th November 2021 9:41:17 pm
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

# Script's usage
get_heredoc usage <<END
    Description: Set of handy utiltiies related to Python installation
    Usage: python.bash COMMAND [ARGS...]

    Commands:

                   add-repo  adds deadsneaks repository to apt's sources
                    rm-repo  removes deadsneaks repository from apt's sources
                    install  installs requested python version
            set-alternative  sets python alternative to the requested version
                             (if version is not installed, installs)

    Options:
      
        --help  if no command given, displays this usage message; if coupled
                with command's name, displays command's usage message
END

# Add-repo usage
get_heredoc add_repo_usage <<END
    Description: Adds deadsnakes repository to apt's sources
    Usage: python.bash add-repo
    
    Options:
      
        --help  displays this usage message
END

# Rm-repo usage
get_heredoc rm_repo_usage <<END
    Description: Removes deadsnakes repository to apt's sources
    Usage: python.bash rm-repo
    
    Options:
      
        --help  displays this usage message
END

# Install usage
get_heredoc install_usage <<END
    Description: Installs python either from the apt package or form source
    Usage: python.bash install TYPE VERSION
    
    Arguments:

           TYPE  type fo the installation to be performed ('src' or 'pkg')
        VERSION  python's version to be installed

    Options:
      
        --help  displays this usage message

    Environment ('src' variant only):

        PYTHON_PREFIX  installation prefix for the python (default: '.')
         PYTHON_FLAGS  additional configuration flags for Python 
    
END

# Set-alternative usage
get_heredoc set_alternative_usage <<END
    Description: Sets alternative for Python executable so that PYTHON_LINK symbolic link
                 points to the given VERSION of the Python

    Usage: python.bash set-alternative VERSION

    Arguments:

        VERSION verison of the Python to be se as default 

    Options:
      
        --help  displays this usage message

    Environment:

         PYTHON_ALT_LINK  name of the symbolic link to be set (default: /usr/bin/python)
         PYTHON_ALT_NAME  name of the alternative to be created in alternatives directory 
                          (@see man update-alternatives) (default: python$VERSION)
         PYTHON_ALT_PATH  path to the executable to link PYTHON_ALT_LINK to (default: /usr/bin/python$VERSION)
        PYTHON_ALT_FLAGS  additional flags to be passed to the call to update-alternatives
END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="python"

# ============================================================ Functions =========================================================== #

install_python_src() {
    

    # Set target's name
    local target=Python$version

    # Dependencies required to build Python from source
    local dependencies=(
        build-essential
    )

    # URL of the Python sources
    local URL="https://www.python.org/ftp/python/$version/Python-$version.tgz"

    # Set default installation prefix
    var_set_default PYTHON_PREFIX '.'

    # Python download directory
    local DOWNLOAD_DIR="/tmp"
    # Prepare names for downloaded archieve
    URL=${URL/tgz/tar.gz}
    prepare_names_for_downloaded_archieve
    URL=${URL/tar.gz/tgz}
    # Path to the extracted Python files
    local EXTRACTED_PATH=$DOWNLOAD_DIR/$EXTRACTED_NAME

    # Check if give Python's version is already installed
    [[ -f $PYTHON_PREFIX/bin/python${version%%.*} ]] && return

    # Install dependencies
    sudo apt update && install_pkg_list -yv --su dependencies

    # Download and extract CMake
    ARCH_NAME=$ARCHIEVE_NAME CURL_FLAGS='-C -' LOG_TARGET="$target" download_and_extract -v \
        $URL $DOWNLOAD_DIR $DOWNLOAD_DIR || return 1
    
    mkdir -p $PYTHON_PREFIX

    # Prepare configuration flags
    local CONFIG_FLAGS="--prefix=$PYTHON_PREFIX --enable-shared ${PYTHON_FLAGS:-}"

    # Build Python
    local SRC_PATH=$EXTRACTED_PATH
    local LOG_TARGET=$target
    make_install_extracted_archieve

}

install_python_pkg() {

    # Check if package is already installed
    which python$version > /dev/null && return

    log_info "Installing Python$version ..."

    # Try to install Python
    sudo apt update && sudo apt install python$version ||
    {
        log_error "Failed to install Python$version. If you given a valid version please make sure"     \
                   "that target oackage reside in the source repository set in apt's soruces. If needed" \
                    "run $0 add-repo to add deadsnakes repository."
        return 1
    }

    log_info "Python$version installed"
}

# ============================================================ Commands ============================================================ #

set_deadsnake_repo() {

    # Name of the Python repository
    local PYTHON_REPO="ppa:deadsnakes/ppa"

    case $cmd in 
        # Add repository
        add_repo ) get_apt_bin_soruces | grep ${PYTHON_REPO#ppa:} > /dev/null || sudo add-apt-repository -y  $PYTHON_REPO;; 
        rm_repo  ) get_apt_bin_soruces | grep ${PYTHON_REPO#ppa:} > /dev/null && sudo add-apt-repository -yr $PYTHON_REPO;; 
    esac

}

install_python() {

    # Parse arguments
    local itype=$1
    local version=$2

    # Dispatch installatino routine
    case $itype in
        src ) install_python_src;;
        pkg ) install_python_pkg;;
        *   ) log_error "Invalid installation type given ($itype)"
              echo $usage
              return 1;;
    esac

}

set_python_alternative() {

    # Get positional argument
    local version=$1

    # Set default environment
    local PYTHON_ALT_LINK=${PYTHON_ALT_LINK:-/usr/bin/python}
    local PYTHON_ALT_NAME=${PYTHON_ALT_NAME:-python$version}
    local PYTHON_ALT_PATH=${PYTHON_ALT_PATH:-/usr/bin/python$version}

    # Check if existing executable given
    [[ -f $PYTHON_ALT_PATH ]] || {
        log_error "Invalid Python executable given ($PYTHON_ALT_PATH)"
        return 1
    }

    # Set alternative
    sudo update-alternatives --install \
        $PYTHON_ALT_LINK               \
        $PYTHON_ALT_NAME               \
        $PYTHON_ALT_PATH               \
        ${PYTHON_ALT_FLAGS:-} ||
    {
        log_error "Could not set python's alternative"
        return 1
    }
    
}

# ============================================================== Main ============================================================== #

main() {

    # ---------------------------------- Configuration ----------------------------------

    # Commands imlemented by the script
    local -a COMMANDS=(
        add_repo
        rm_repo
        install
        set_alternative
    )

    # Number of required arguments
    local install_ARG_NUM=2
    local set_alternative_ARG_NUM=1

    # Options
    local opt_definitions=(
        '--help',help,f
    )

    # ------------------------------------ Processing -----------------------------------

    # Parsed options
    parse_script_options_multicmd
    
    # Perform corresponding routine
    case $cmd in
        add_repo|rm_repo ) set_deadsnake_repo;;
        install          ) install_python $@;;
        set_alternative  ) set_python_alternative $@;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

