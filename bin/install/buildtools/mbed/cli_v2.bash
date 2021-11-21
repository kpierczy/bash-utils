#!/usr/bin/env bash
# ====================================================================================================================================
# @file     cli_v2.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Sunday, 21st November 2021 8:34:01 pm
# @modified Sunday, 21st November 2021 9:03:48 pm
# @project  BashUtils
# @brief
#    
#    Installs Mbed CLI v2
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Source BashUitils library
source $BASH_UTILS_HOME/source_me.bash

# ============================================================== Usage ============================================================= #

# Script's usage
get_heredoc usage <<END
    Description: Installs Mbed CLI utility (version 2)
    Usage: cli_v2.bash

    Options:
      
                    -help  if no command given, displays this usage message
             --print-path  if given, prints path to the directory that needs to be in PATH to use CLI
                           to the file descriptor No. 3
          --with-mbed=DIR  if given also installs python packages required by the Mbed
END

# ============================================================ Constants =========================================================== #

# Logging context of the script
LOG_CONTEXT="mbed"

# ============================================================ Commands ============================================================ #

install() {

    # Dependencies of the Mbed CLI
    locla -a dependencies=( ninja-build )
    # Install dependencies
    install_pkg_list --su -y -v -U dependencies || {
        log_error "Failed to install dependencies"
        exit 1
    }

    # If Mbed root given, install Python dependencies
    if is_var_set_non_empty options[mbed_root]; then

        # If valid Mbed root has been given, install dependencies
        if [[ -f ${options[mbed_root]}/requirements.txt ]]; then

            # @note Here the list of installed Python packages is acquired directly from the `pip list`
            #    and no @fun is_pip_package_installed() function is used. As a call to `pip list` is
            #    quite time-consuming, such approach makes the whole script noticeably faster

            # Get list of all packages
            packages=$(python3 -m pip list 2> /dev/null)

            # Iterate over requirements file's lines and check all requirements
            while read requirement; do

                # Filter  only package's name
                package=$(echo "$requirement" | awk -F '=|>|<|\[' '{print $1;}')

                # Check whether package is aimed for Linux
                if ! is_substring $requirement 'platform_system!="Linux"' && ! is_substring $requirement "platform_system=='Windows'" then

                    # If so, check if package is installed
                    if ! echo $packages | grep -i $package > /dev/null; then

                        # If ANY package's not installed, install requirements
                        log "Updating Mbed python dependencies..."
                        PIP_FLAGS='-r' pip_install -v ${options[mbed_root]}/requirements.txt
                        break
                        
                    fi
                fi

            done < ${options[mbed_root]}/requirements.txt

        # Otherwise, exit with error
        else
            log_error "Invalid  Mbed root given (${options[mbed_root]})"
            exit 1
        fi

    fi

    # Install CLI
    install_pkg --su -y -v -U "mbed-tools" || {
        log_error "Failed to install CLI"
        exit 1
    }

    # Write path to the CLI's binaries, if requested
    is_var_set_non_empty options[print_path] && {
        echo "~/.local/bin" >&3
    }
    
}

# ============================================================== Main ============================================================== #

main() {

    # Link USAGE message
    local -n USAGE=usage

    # Options
    local -a opt_definitions=(
        '--help',help,f
        '--print-path',print_path,f
        '--with-mbed',mbed_root
    )

    # Make options' parsing verbose
    local VERBOSE_PARSEARGS=1

    # Parse arguments
    parse_arguments

    # Run installation script
    install

}

# ============================================================= Script ============================================================= #

# Run the script
source $BASH_UTILS_HOME/lib/scripting/templates/base.bash

