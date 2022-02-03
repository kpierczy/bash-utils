#!/usr/bin/env bash
# ====================================================================================================================================
# @file     net.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 9:59:21 pm
# @modified Sunday, 21st November 2021 3:37:11 pm
# @project  bash-utils
# @brief
#    
#    Set of tools related to manipulating files in remote servers
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Downloads the file via `wget` and writes path to the 
#    downloaded file to the stdout
# 
# @param ...
#    arguments to be passed to wget
#
# @returns 
#    @c 0 on success \n
#    @c 1 on error \n
#    @c 2 if file was already downloaded and was not downloaded 
#         again (--no-clobber option was passed)
# 
# @note Output of the `wget` command is forced to be redirected
#    to the log file and so caller cannot configre it to print
#    log messages to the stderr via options. It is still possible
#    though to make the progress bar visible with --show-progress 
#    switch
# 
# @note If many files would be downloaded by `wget`, only location
#    of the first one is returned to the stdout
# -------------------------------------------------------------------
function wget_and_localize() {

    # Arguments
    url_="$1"

    # ----------------- Download the file -----------------

    # Create a temporary file for log output
    local logfile_
    logfile_="$(mktemp)" || return 1

    # Check if progress is to be displayed
    local -a __args_=( "$@" )
    if is_array_element __args_ "--show-progress"; then
        local show_progres_flag_="--show-progress" 
    fi
    
    # Download requested file
    wget "$@" --output-file="$logfile_" --no-verbose "${show_progres_flag_:-}" && ret_=$? || ret_=$?
    
    # ----------------- Localize the file -----------------
    
    local log_
    local out_file_
    
    # If file was successfully downloaded, parse the log file
    if [[ "$ret_" == "0" ]]; then

        # Try to parse the downloaded file
        out_file_=$(cut -d '"' -f2 < $logfile_)
        # Return success status code if name was parsed sucesfully
        if is_var_set_non_empty out_file_; then
            ret_=0
        # Else, check whether file was already downloaded
        else

            # In case file was already downloaded, reproduce logfile with --verbose flag
            wget "$@" --output-file="$logfile_" --verbose &> /dev/null
            # Read content of the logfile
            log_=$(cat $logfile_)
            # Remove text around the name of the file to be extracted
            local prefixless_=${log_#File }
            local suffixless_=${prefixless_% already*}
            # Get the ROI (remove '' around the file's name)
            out_file_=${suffixless_:1:-1}
            # Return status code
            is_var_set_non_empty out_file_ && 
                ret_=2 || ret_=1

        fi
        
    # If error code was returned, check whether an empty/buggy log was produced
    #
    # 1) If the empty log was produced, the --no-clobber option was passed (along
    #    with --output-document) and the file was already downloaded. 
    #
    # 2) (wget bug) When the "http://: Invalid host name." log was produced, the
    #    function was called passed with --no-clobber option and  WITHOUT 
    #    --output-document option (downloaded file has default name ) and the file 
    #    was already downloaded. 
    #    
    # In such cases `wget` can be rerun in verbose mode to produce the new log 
    # that will contain the name of already downloaded file
    elif [[ -z $(cat "$logfile_") || "$(cat $logfile_)" == "http://: Invalid host name." ]]; then
      
        # Rerun the wget with --verbose mode to produce an non-empty log file
        # that will contain name of the 'already downloaded' file (redirect
        # user output - stderr - to null)
        wget "$@" --output-file="$logfile_" --verbose &> /dev/null
        
        # Read content of the logfile
        log_=$(cat $logfile_)
        # Remove text around the name of the file to be extracted
        local prefixless_=${log_#File }
        local suffixless_=${prefixless_% already*}
        # Get the ROI (remove '' around the file's name)
        out_file_=${suffixless_:1:-1}

        # If file was already downloaded, return 2 status code
        ret_=2

        # If $out_file_ was not succesfully parsed, the log file has no an expected form
        is_var_set_non_empty out_file_ || {

            # Remove log file
            rm -rf "$logfile_"
            # In such a case report an error
            ret_=1

        }

    # If non-empty log was produced and error code was returned
    else
        
        # ----------------------------------------------------------
        # @note There is a bug in the `wget` emerging when the file
        #    is downloaded without '--progress-bar' option. Inspite
        #    of success download of the file, the `1` error code is
        #    returned.
        # 
        #    In such case, the function tries to parse the log file
        #    nonetheless using the usual pattern. Only if fails to
        #    do so, the error is reported
        # ----------------------------------------------------------
        
        # Read content of the logfile
        log_=$(cat $logfile_)
        
        # Check if content, matches the valid pattern (pattern: ...-> "<filename>" [1]...)
        if [[ "$log_" =~ \-\>[[:space:]]\".*\"[[:space:]]\[1\] ]]; then
        
            # Get matched content
            matched_="${BASH_REMATCH[0]}"
            # Remove prefix and suffix from the matched pattern
            matched_="${matched_#"-> \""}"
            matched_="${matched_%"\" [1]"}"
            out_file_="$matched_"

            # Return success status code, if parsed
            ret_=0
            
            # Check, whether file's named was sucesfully parsed
            is_var_set_non_empty out_file_ || {

                # Remove log file
                rm -rf "$logfile_"
                # In such a case report an error
                ret_=1
            }

        # If no content matched, return error
        else

            # Remove log file
            rm -rf "$logfile_"
            # In such a case report an error
            ret_=1
            
        fi

    fi
    
    # Remove log file
    rm -rf "$logfile_"

    # If no error occurred, print path to the output file to stdout
    [[ "$ret_" != "1" ]] && echo "$out_file_"

    # Return status code
    return $ret_

}
