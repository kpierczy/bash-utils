#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cli_v2.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 8:34:01 pm
# @modified Wednesday, 23rd February 2022 12:10:04 am
# @project  bash-utils
# @brief
#    
#    Installs Mbed CLI v2
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Description of the script
declare cmd_description="Installs Mbed CLI utility (version 2)"

# Options' descriptions
declare -A opts_description=(
    [print_path]="if given, prints path to the directory that needs to be in PATH to use CLI to the file descriptor No. 3"
    [mbed_root]="if given also installs python packages required by the Mbed"
)

# ============================================================ Constants =========================================================== #

# Logging context of the script
declare LOG_CONTEXT="mbed"

# ============================================================ Commands ============================================================ #

function install() {

    # ---------------------------- Installing dependencies ------------------------------
    
    # Dependencies of the Mbed CLI
    local -a dependencies=( ninja-build )
    # Install dependencies
    install_pkg_list --su -y -v dependencies || {
        log_error "Failed to install dependencies"
        exit 1
    }

    # -------------------------------- Installing CLI -----------------------------------
    
    # If Mbed root given, install Python dependencies
    if is_var_set_non_empty opts[mbed_root]; then

        # If valid Mbed root has been given, install dependencies
        if [[ -f ${opts[mbed_root]}/requirements.txt ]]; then

            # @note Here the list of installed Python packages is acquired directly from the `pip list`
            #    and no @fun is_pip_package_installed() function is used. As a call to `pip list` is
            #    quite time-consuming, such approach makes the whole script noticeably faster
    
            # Get list of all packages
            packages=$(python3 -m pip list 2> /dev/null)

            # Iterate over requirements file's lines and check all requirements
            while read requirement; do

                # Filter  only package's name
                package=$(echo "$requirement" | awk -F '[=><\[]' '{print $1;}' 2> /dev/null)

                # Check whether package is aimed for Linux
                if ! is_substring $requirement 'platform_system!="Linux"' && ! is_substring $requirement "platform_system=='Windows'"; then

                    # If so, check if package is installed
                    if ! echo $packages | grep -i $package > /dev/null; then

                        # If ANY package's not installed, install requirements
                        log_info "Updating Mbed python dependencies..."
                        PIP_FLAGS='-r' pip_install -v ${opts[mbed_root]}/requirements.txt
                        break
                        
                    fi
                fi

            done < ${opts[mbed_root]}/requirements.txt

        # Otherwise, exit with error
        else
            log_error "Invalid  Mbed root given (${opts[mbed_root]})"
            exit 1
        fi

    fi

    # Install CLI
    pip_install -v -U "mbed-tools" || {
        log_error "Failed to install CLI"
        exit 1
    }

    # Write path to the CLI's binaries, if requested
    if is_var_set_non_empty opts[print_path]; then
        echo "~/.local/bin" >&3
    fi

}

# ============================================================== Main ============================================================== #

function main() {

    # Options
    local -A a_print_path_opt_def=( [format]="--print-path" [name]="print_path" [type]="f" )
    local -A  b_with_mbed_opt_def=( [format]="--with-mbed"  [name]="mbed_root"  [type]="p" )

    # Set help generator's configuration
    ARGUMENTS_DESCRIPTION_LENGTH_MAX=120
    # Parsing options
    declare -a PARSEARGS_OPTS
    PARSEARGS_OPTS+=( --with-help )
    PARSEARGS_OPTS+=( --verbose   )
    
    # Parsed options
    parse_arguments
    # If help requested, return
    if [[ $ret == '5' ]]; then
        return
    elif [[ $ret != '0' ]]; then
        return $ret
    fi

    # Run installation script
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

