#!/usr/bin/env bash
# ====================================================================================================================================
# @file     python.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Saturday, 6th November 2021 4:29:08 pm
# @modified Wednesday, 23rd February 2022 12:06:37 am
# @project  bash-utils
# @brief
#    
#    Installs the given version of the Python
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ========================================================== Script usage ========================================================== #

# Description of the script
declare cmd_description="Set of handy utiltiies related to Python installation"

# Arguments' descriptions
declare -A pargs_description=(
    [cmd]="command to be executed"
    [arg]="arguments passed to the command"
)

# Options' descriptions
declare -A opts_description=(
    [help]="if no command given, displays this usage message; if coupled with command's name, displays command's usage message"
)

# Command's description
get_heredoc commands_description <<END
    Commands:

               add-repo  adds deadsneaks repository to apt's sources
                rm-repo  removes deadsneaks repository from apt's sources
                install  installs requested python version
        set-alternative  sets python alternative to the requested version (if version is not installed, installs)
END

# ========================================================= Add-repo usage ========================================================= #

# Description of the add-repo utility
declare add_repo_description="Adds deadsnakes repository to apt's sources"
# Name of the add-repo utility
declare add_repo_name="python.bash add-repo"

# ========================================================= Rm-repo utility ======================================================== #

# Description of the rm-repo utility
declare rm_repo_description="Removes deadsnakes repository from apt's sources"
# Name of the rm-repo utility
declare rm_repo_name="python.bash rm-repo"

# ========================================================= Install utility ======================================================== #

# Description of the install utility
declare install_description="Installs python either from the apt package or from source"
# Name of the install utility
declare install_name="python.bash install"

# Arguments' descriptions
declare -A install_pargs_description=(
    [type]="type for the installation to be performed ('src' or 'pkg')"
    [version]="python's version to be installed"
)
# Opts' descriptions
declare -A install_opts_description=(
    [download_prefix]="dowload prefix for the python; valid only for 'src' installation"
    [prefix]="installation prefix for the python; valid only for 'src' installation"
)
# Envs' descriptions
declare -A install_envs_description=(
    [flags]="additional configuration flags for Python "
)

# ===================================================== Set-alternatives usage ===================================================== #

# Description of the set-alternative utility
declare set_alternative_description="Sets alternative for Python executable so that PYTHON_LINK symbolic link points to the given VERSION of the Python"
# Name of the set-alternative utility
declare set_alternative_name="python.bash set-alternative"

# Arguments' descriptions
declare -A set_alternative_pargs_description=(
    [version]="verison of the Python to be se as default"
)
# Envs' descriptions
declare -A set_alternative_envs_description=(
    [alt_link]="name of the symbolic link to be set"
    [alt_name]="name of the alternative to be created in alternatives directory  (@see man update-alternatives)"
    [alt_path]="path to the executable to link PYTHON_ALT_LINK to"
    [alt_flags]="name of the array holding additional flags to be passed to the call to update-alternatives"
)

# ============================================================ Constants =========================================================== #

# Name of the Python repository
declare PYTHON_REPO="ppa:deadsnakes/ppa"
# URL of the Python sources
declare PYTHON_URL_SCHEME="https://www.python.org/ftp/python/\$VERSION/Python-\$VERSION.tgz"

# Logging context of the script
declare LOG_CONTEXT="python"

# ================================================================================================================================== #
# ----------------------------------------------------------- Functions ------------------------------------------------------------ #
# ================================================================================================================================== #

function cleanup_main_args() {

    # Unse arguments' descriptiors
    unset a_cmd_parg_def
    unset b_args_parg_def
    # Unse options' descriptiors
    unset help_opt_def
    # Unse envs
    unset PARSEARGS_OPTS

}


function install_python_src() {

    # Python download directory
    local download_dir="$(realpath ${opts[download_prefix]})"
    # Set target's name
    local target=python${pargs[version]}

    # ---------------------------- Installing dependencies ------------------------------

    # Dependencies required to build Python from source
    local dependencies=(
        build-essential
    )

    # Install dependencies
    sudo apt update && install_pkg_list -yv --su dependencies
    
    # --------------------------- Installing python package -----------------------------

    # Get source URL
    local url=$(VERSION=${pargs[version]} eval "echo $PYTHON_URL_SCHEME")
    # Create path to the downloaded archieve
    local archieve_name=${url##*\/}
    local archieve_path=${download_dir}/${archieve_name}
    # Create name of the extracted archieve
    local extracted_name=${archieve_name%%.tgz}

    # Prepare additional flags for `wget`
    local -a WGET_FLAGS=()
    WGET_FLAGS+=( --continue )
    # Prepare additional flags for `configure`
    local -a CONFIG_FLAGS=()
    CONFIG_FLAGS+=( --prefix=$(realpath ${opts[prefix]}) )
    CONFIG_FLAGS+=( --enable-shared                      )
    # Add custom flags
    is_var_set envs[flags] && {
        local -n flags=${envs[flags]}
        CONFIG_FLAGS+=( ${flags[@]} )
    }

    # Check if give Python's version is already installed
    [[ -f ${opts[prefix]}/bin/python${pargs[version]%.*} ]] && return

    # Doanload build and isntall
    download_build_and_install                          \
        --verbose                                       \
        --arch-path=$archieve_path                      \
        --extract-dir=$download_dir                     \
        --src-dir=$extracted_name                       \
        --build-dir=$download_dir/$extracted_name/build \
        --show-progress                                 \
        --log-target=$target                            \
        --mark                                          \
        $url

}

function install_python_pkg() {

    # Set target's name
    local target=python${pargs[version]}
    
    # Check if package is already installed
    which $target > /dev/null && return

    log_info "Installing \`$target\` ..."

    # Try to install Python
    sudo apt update && sudo apt install $target ||
    {
        log_error "Failed to install \`$target\`. If you given a valid version please make sure"        \
                  "that target oackage reside in the source repository set in apt's soruces. If needed" \
                  "run $(basename $0) add-repo to add deadsnakes repository."
        return 1
    }

    log_info "\`$target\` installed"
}

# ============================================================ Commands ============================================================ #

function add_deadsnake_repo() {

    # Cleanup main
    cleanup_main_args

    # Command' description
    local -n cmd_description=add_repo_description
    # Command' name
    local -n cmd_name=add_repo_name

    # Parsing options
    local -a PARSEARGS_OPTS=()
    PARSEARGS_OPTS+=( --verbose   )
    PARSEARGS_OPTS+=( --with-help )

    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    fi

    # Add repository
    if ! get_apt_bin_soruces | grep ${PYTHON_REPO#ppa:} > /dev/null; then
        sudo add-apt-repository -y $PYTHON_REPO
    fi

}

function rm_deadsnake_repo() {

    # Cleanup main
    cleanup_main_args

    # Command' description
    local -n cmd_description=rm_repo_description
    # Command' name
    local -n cmd_name=rm_repo_name

    # Parsing options
    local -a PARSEARGS_OPTS=()
    PARSEARGS_OPTS+=( --verbose   )
    PARSEARGS_OPTS+=( --with-help )

    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    fi
    
    # Remove repository
    if get_apt_bin_soruces | grep ${PYTHON_REPO#ppa:} > /dev/null; then
        sudo add-apt-repository -yr $PYTHON_REPO
    fi

}

function install_python() {

    # Cleanup main
    cleanup_main_args

    # ------------------------------- Arguments' parsing --------------------------------

    # Command' description
    local -n cmd_description=install_description
    # Command' name
    local -n cmd_name=install_name

    # Pargs definitions
    local -A     a_type_parg_def=( [format]="TYPE"    [name]="type"    [type]="s" [variants]="src | pkg" )
    local -A  b_version_parg_def=( [format]="VERSION" [name]="version" [type]="s"                        )
    # Pargs descriptions
    local -n pargs_description=install_pargs_description

    # Opts definitions
    local -A  a_downloadprefix_opt_def=( [format]="--download-prefix" [name]="download_prefix" [type]="p" [default]="/tmp" )
    local -A          b_prefix_opt_def=( [format]="--prefix"          [name]="prefix"          [type]="p" [default]="."    )
    # Opts descriptions
    local -n opts_description=install_opts_description

    # Envs definitions
    local -A  flags_env_def=( [format]="PYTHON_FLAGS" [name]="flags" [type]="s" )
    # Envs descriptions
    local -n envs_description=install_envs_description

    # Parsing options
    local -a PARSEARGS_OPTS=()
    PARSEARGS_OPTS+=( --verbose   )
    PARSEARGS_OPTS+=( --with-help )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    fi

    # ------------------------------------ Processing -----------------------------------

    # Dispatch installatino routine
    case ${pargs[type]} in
        src ) install_python_src;;
        pkg ) install_python_pkg;;
    esac

}

function set_python_alternative() {

    # Cleanup main
    cleanup_main_args

    # ------------------------------- Arguments' parsing --------------------------------

    # Command' description
    local -n cmd_description=set_alternative_description
    # Command' name
    local -n cmd_name=set_alternative_name

    # Pargs definitions
    local -A  version_parg_def=( [format]="VERSION" [name]="version" [type]="s" )
    # Pargs descriptions
    local -n pargs_description=set_alternative_pargs_description

    # Envs definitions
    local -A  a_alt_link_env_def=( [format]="PYTHON_ALT_LINK"  [name]="alt_link"  [type]="s" [default]="/usr/bin/python"          )
    local -A  b_alt_name_env_def=( [format]="PYTHON_ALT_NAME"  [name]="alt_name"  [type]="s" [default]="python\$VERSION"          )
    local -A  c_alt_path_env_def=( [format]="PYTHON_ALT_PATH"  [name]="alt_path"  [type]="s" [default]="/usr/bin/python\$VERSION" )
    local -A d_alt_flags_env_def=( [format]="PYTHON_ALT_FLAGS" [name]="alt_flags" [type]="s"                                      )
    # Envs descriptions
    local -n envs_description=set_alternative_envs_description

    # Parsing options
    local -a PARSEARGS_OPTS=()
    PARSEARGS_OPTS+=( --verbose   )
    PARSEARGS_OPTS+=( --with-help )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    fi

    # ------------------------------------ Processing -----------------------------------

    # Evalueate default environments
    envs[alt_link]=$( VERSION=${pargs[version]} eval "echo ${envs[alt_link]}"  )
    envs[alt_name]=$( VERSION=${pargs[version]} eval "echo ${envs[alt_name]}" )
    envs[alt_path]=$( VERSION=${pargs[version]} eval "echo ${envs[alt_path]}" )
    

    # Check if existing executable given
    [[ -f ${envs[alt_path]} ]] || {
        log_error "Invalid Python executable given (${envs[alt_path]})"
        return 1
    }

    # Get additional flags to be passed
    local -a additional_flags=()
    if is_var_set envs[alt_flags]; then
        local -n additional_flags=${envs[alt_flags]}
    fi

    # Set alternative
    sudo update-alternatives --install \
        ${envs[alt_link]}              \
        ${envs[alt_name]}              \
        ${envs[alt_path]}              \
        ${additional_flags[@]}         ||
    {
        log_error "Could not set python's alternative"
        return 1
    }
    
}

# ================================================================================================================================== #
# -------------------------------------------------------------- Main -------------------------------------------------------------- #
# ================================================================================================================================== #

function main() {

    # ------------------------------- Arguments' parsing --------------------------------

    # Arguments
    local -A  a_cmd_parg_def=( [format]="COMMAND" [name]="cmd"  [type]="s" [variants]="add-repo | rm-repo | install | set-alternative" )
    local -A b_args_parg_def=( [format]="ARGS..." [name]="arg"  [type]="s"                                                             )

    # Options
    local -A help_opt_def=( [format]="-h|--help" [name]="help" [type]="f" )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    local -a PARSEARGS_OPTS=()
    PARSEARGS_OPTS+=( --verbose   )
    PARSEARGS_OPTS+=( --with-append-pargs-description=commands_description )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi
    
    # ------------------------------------ Processing -----------------------------------

    # Set script's arguments to variadic ones
    eval "set -- ${parsed[@]:1}"
    
    # Perform corresponding routine
    case ${pargs[cmd]} in
        add-repo        ) add_deadsnake_repo     $@ ;;
        rm-repo         ) rm_deadsnake_repo      $@ ;;
        install         ) install_python         $@ ;;
        set-alternative ) set_python_alternative $@ ;;
    esac
    
}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash
