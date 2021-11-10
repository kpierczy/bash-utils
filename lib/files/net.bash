#!/usr/bin/env bash
# ====================================================================================================================================
# @file     net.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 9th November 2021 9:59:21 pm
# @modified Wednesday, 10th November 2021 5:48:11 am
# @project  BashUtils
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
#    @c 1 on error
# 
# @note Output of the `wget` command is forced to be redirected
#    to the log file and so caller cannot configre it to print
#    log messages to the stderr via options. It is still possible
#    though to make the progress bar visible with --show-progress 
#    switch
# -------------------------------------------------------------------
function wget_and_localize() {

   # ---------------- Parse arguments ----------------

    # Options taken by the `wget` command
    local -a opt_definitions=(
                     '-V|--version',version,f
                        '-h|--help',help,f
                  '-b|--background',background,f
                     '-e|--execute',execute
                 '-o|--output-file',output_file
               '-a|--append-output',append_output
                       '-d|--debug',debug,f
                       '-q|--quiet',quiet,f
                     '-v|--verbose',verbose,f
                 '-nv|--no-verbose',no_verbose,f
                   '--report-speed',report_speed
                  '-i|--input-file',input_file
                  '-F|--force-html',force_html,f
                        '-B|--base',base
                         '--config',config
                      '--no-config',no_config,f
                   '--rejected-log',rejected_log
                       '-t|--tries',tries
              '--retry-connrefused',retry_connrefused,f
            '--retry-on-http-error',retry_on_http_error
             '-O|--output-document',output_document
                 '-nc|--no-clobber',no_clobber,f
                       '--no-netrc',no_netrc,f
                    '-c|--continue',continue,f
                      '--start-pos',start_pos
                       '--progress',progress
                  '--show-progress',show_progress,f
                '-N|--timestamping',timestamping,f
           '--no-if-modified-since',no_if_modified_since,f
       '--no-use-server-timestamps',no_use_server_timestamps,f
             '-S|--server-response',server_response,f
                         '--spider',spider,f
                     '-T|--timeout',timeout
                    '--dns-timeout',dns_timeout
                '--connect-timeout',connect_timeout
                   '--read-timeout',read_timeout
                        '-w|--wait',wait
                      '--waitretry',waitretry
                    '--random-wait',random_wait,f
                       '--no-proxy',no_proxy,f
                       '-Q|--quota',quota
                   '--bind-address',bind_address
                     '--limit-rate',limit_rate
                   '--no-dns-cache',no_dns_cache,f
            '--restrict-file-names',restrict_file_names
                    '--ignore-case',ignore_case,f
                           '--inet',inet,f
                           '--inet',inet,f
                  '--prefer-family',prefer_family
                           '--user',user
                       '--password',password
                   '--ask-password',ask_password,f
                    '--use-askpass',use_askpass
                         '--no-iri',no_iri,f
                 '--local-encoding',local_encoding
                '--remote-encoding',remote_encoding
                         '--unlink',unlink,f
                          '--xattr',xattr,f
             '-nd|--no-directories',no_directories,f
           '-x|--force-directories',force_directories,f
        '-nH|--no-host-directories',no_host_directories,f
           '--protocol-directories',protocol_directories,f
            '-P|--directory-prefix',directory_prefix
                       '--cut-dirs',cut_dirs
                      '--http-user',http_user
                  '--http-password',http_password
                       '--no-cache',no_cache,f
                   '--default-page',default_page
            '-E|--adjust-extension',adjust_extension,f
                  '--ignore-length',ignore_length,f
                         '--header',header
                    '--compression',compression
                   '--max-redirect',max_redirect,f
                     '--proxy-user',proxy_user
                 '--proxy-password',proxy_password
                        '--referer',referer
                   '--save-headers',save_headers,f
                  '-U|--user-agent',user_agent
             '--no-http-keep-alive',no_http_keep_alive,f
                     '--no-cookies',no_cookies,f
                   '--load-cookies',load_cookies
                   '--save-cookies',save_cookies
           '--keep-session-cookies',keep_session_cookies,f
                      '--post-data',post_data
                      '--post-file',post_file
                         '--method',method
                      '--body-data',body_data
                      '--body-file',body_file
            '--content-disposition',content_disposition,f
               '--content-on-error',content_on_error,f
              '--auth-no-challenge',auth_no_challenge,f
                '--secure-protocol',secure_protocol
                     '--https-only',https_only,f
           '--no-check-certificate',no_check_certificate,f
                    '--certificate',certificate
               '--certificate-type',certificate_type
                    '--private-key',private_key
               '--private-key-type',private_key_type
                 '--ca-certificate',ca_certificate
                   '--ca-directory',ca_directory
                       '--crl-file',crl_file
                   '--pinnedpubkey',pinnedpubkey
                    '--random-file',random_file
                        '--ciphers',ciphers
                '--secure-protocol',secure_protocol,f
                        '--no-hsts',no_hsts,f
                      '--hsts-file',hsts_file,f
                       '--ftp-user',ftp_user
                   '--ftp-password',ftp_password
              '--no-remove-listing',no_remove_listing,f
                        '--no-glob',no_glob,f
                 '--no-passive-ftp',no_passive_ftp,f
           '--preserve-permissions',preserve_permissions,f
                  '--retr-symlinks',retr_symlinks,f
                  '--ftps-implicit',ftps_implicit,f
                '--ftps-resume-ssl',ftps_resume_ssl,f
     '--ftps-clear-data-connection',ftps_clear_data_connection,f
           '--ftps-fallback-to-ftp',ftps_fallback_to_ftp,f
                      '--warc-file',warc_file
                    '--warc-header',warc_header
                  '--warc-max-size',warc_max_size
                       '--warc-cdx',warc_cdx,f
                     '--warc-dedup',warc_dedup
            '--no-warc-compression',no_warc_compression,f
                '--no-warc-digests',no_warc_digests,f
               '--no-warc-keep-log',no_warc_keep_log,f
                   '--warc-tempdir',warc_tempdir
                   '-r|--recursive',recursive,f
                       '-l|--level',level
                   '--delete-after',delete_after,f
               '-k|--convert-links',convert_links,f
              '--convert-file-only',convert_file_only,f
                        '--backups',backups
            '-K|--backup-converted',backup_converted,f
                      '-m|--mirror',mirror,f
             '-p|--page-requisites',page_requisites,f
                '--strict-comments',strict_comments,f
                      '-A|--accept',accept
                      '-R|--reject',reject
                   '--accept-regex',accept_regex
                   '--reject-regex',reject_regex
                     '--regex-type',regex_type
                     '-D|--domains',domains
                '--exclude-domains',exclude_domains
                     '--follow-ftp',follow_ftp,f
                    '--follow-tags',follow_tags
                    '--ignore-tags',ignore_tags
                  '-H|--span-hosts',span_hosts,f
                    '-L|--relative',relative,f
         '-I|--include-directories',include_directories
             '--trust-server-names',trust_server_names,f
         '-X|--exclude-directories',exclude_directories
                  '-np|--no-parent',no_parent,f
    )

    # Disable word-splitting to parse positional arguments in a proper way
    push_stack "$IFS"
    disable_word_splitting

    # Parse arguments to a named array
    local -a args=( "$@" )

    # Restore previous mode of the word-splitting
    pop_stack IFS

    # Prepare names hash arrays for positional arguments and parsed options
    local -a posargs
    local -A options

    # Parse options
    parseopts args opt_definitions options posargs || return 1

    # Parse arguments
    url_="${posargs[1]}"

    # -------------------------------------------------

    local out_file_=''

    # Check if both --output-document and --no-clobber options are set
    # (@note if both options are set and the target file already exists
    # the log file will be empty and so it will be not possible to
    # read a path from it. In this case, the target file may be read
    # from the value of the --output-document though)
    if is_var_set output_document && is_var_set no_clobber; then
        out_file_=options[output_document]
    fi

    # Create a temporary file for log output
    local logfile_
    logfile_="$(mktemp)" || return 1

    # Check if progress is to be displayed
    local show_progres_flag_=''
    is_var_set options[show_progress] &&
        show_progres_flag_="--show-progress"

    # Download requested file
    wget "$@" --output-file="$logfile_" -nv "$show_progres_flag_" > /dev/null || return 1
    
    # Parse logfile to get output file's path
    cat $logfile_ 1>&2
    # is_var_set_non_empty out_file_ || out_file_=$(cut -d '"' -f2 < $logfile_)
    # If out_file_ still empty, file had been already downloaded and the --no-clobber option
    # has been passed. Use another parsing scheme
    is_var_set_non_empty out_file_ || {

        local log_=$(cat $logfile_)
        # Parse prefix and suffix of the ROI
        local prefixless_=${log_#File }
        local suffixless_=${prefixless_% already*}
        # Get the ROI
        out_file_=${suffixless_:1:-1}

    }
    
    # Remove temporary file
    rm -rf "$logfile_"

    # Print path to the output file to stdout
    echo "$out_file_"

}

