#!/usr/bin/env bash
# ====================================================================================================================================
# @file     logging.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Wednesday, 3rd November 2021 3:08:34 am
# @modified Thursday, 4th November 2021 12:03:30 am
# @project  BashUtils
# @brief
#    
#    Set of general logging utilities
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# Get path to the librarie's home
LIB_HOME="$(dirname "$(readlink -f "$BASH_SOURCE")")/../.."

# Source variables helper
source $LIB_HOME/lib/scripting/variables.bash

# ============================================================ Constants =========================================================== #

# Log levels available in the library (RFC 5424)
declare  DEBUG_LEVEL=7
declare   INFO_LEVEL=6
declare NOTICE_LEVEL=5
declare   WARN_LEVEL=4
declare  ERROR_LEVEL=3
declare   CRIT_LEVEL=2
declare  ALERT_LEVEL=1
declare  EMERG_LEVEL=0

# Colours associated with log levels
declare -A LOG_COLOURS=(
   [DEBUG]='\033[34m' # Blue
    [INFO]='\033[32m' # Green
  [NOTICE]=''         # (Unused)
    [WARN]='\033[33m' # Yellow
   [ERROR]='\033[31m' # Red
    [CRIT]=''         # (Unused)
   [ALERT]=''         # (Unused)
   [EMERG]=''         # (Unused)
 [DEFAULT]='\033[0m'  # White
)

# ========================================================== Configuration ========================================================= #

# Current logging level
var_set_default LOG_LEVEL $WARN_LEVEL
# Optional log files
var_set_default LOG_FILE      ''
var_set_default LOG_JSON_FILE ''
# Syslog configuration
var_set_default LOG_SYSLOG           0
var_set_default LOG_SYSLOG_TAG      ''
var_set_default LOG_SYSLOG_FACILITY ''
# Configuration of time logging
var_set_default LOG_TIME 0
# Format of the time log (as for `data` command) [default: %F %T]
var_set_default LOG_TIME_FORMAT ''
# Configuration of the colout scheme
var_set_default LOG_COLOUR_WHOLE 0

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Helper function used to log an error message with
#    neither file output nor syslog output
# -------------------------------------------------------------------
_log_exception() {
    
    local LOG_FILE=''
    local LOG_JSON=''
    local LOG_SYSLOG=0

    log error "Logging Exception: ${@}";
}

# -------------------------------------------------------------------
# @brief Logs a @p msg message with @level log level to the stdout
#    with an optional @p context 
# 
# @param level
#    logging level. Logging level can be (case-insensitive):
#
#       - debug  (LOG_VELEL >= DEBUG_LEVEL)
#       - info   (LOG_VELEL >= INFO_LEVEL)
#       - notice (LOG_VELEL >= NOTICE_LEVEL)
#       - warn   (LOG_VELEL >= WARN_LEVEL)
#       - error  (LOG_VELEL >= ERROR_LEVEL)
#       - crit   (LOG_VELEL >= CRIT_LEVEL)
#       - alert  (LOG_VELEL >= ALERT_LEVEL)
#       - emerg  (LOG_VELEL >= EMERG_LEVEL)
#
# @param context (optional)
#    context string of the message
# @param msg
#    message to be logged
#
# @environment
# 
#   @var LOG_LEVEL (integer)
#       current log level; if lower than @p level, log is not printed to the stdout
#   @var LOG_FILE (path)
#       path to the optional log file (unused if '' or unset)
#   @var LOG_JSON_FILE (path)
#       path to the optional JSON log file (unused if '' or unset)
#   @var LOG_SYSLOG (boolean)
#       if @c 1, log will be written to the syslog
#   @var LOG_SYSLOG_TAG
#       syslog tag (default: $(basename "${0}"))
#   @var LOG_SYSLOG_FACILITY
#       syslog facility (default: local0)
#   @var LOG_TIME (boolean)
#       if @c 1, log will be written with the time stamp
#   @var LOG_TIME_FORMAT (string)
#       format of the date time (compatible with `date`)
#   @var LOG_COLOUR_WHOLE (boolean)
#       if @c 1, log will be fully coloured \n
#       if @c 0, only date, log level and context will be printed in colour
#
# -------------------------------------------------------------------
log() {

    # Arguments
    local level=$1
    local context=''
    local msg=''

    # Parse arguments
    if [[ $# -eq 3 ]]; then
        context=$2
        msg=$3
    else
        msg=$2
    fi

    # Convert level to uppercase for choosing log colours and checking current log level
    local level_upper="$(echo "${level}" | awk '{print toupper($0)}')";

    # Get date format
    local date_format="${LOG_TIME_FORMAT:-+%F %T}";
    # Get date
    local date="$(date "${date_format}")";
    # Get date
    local date_s_since_epoch="$(date "+%s")";

    # Get severity level of the log
    local -n log_severity=${level_upper}_LEVEL

    # ---------------------- Syslog ----------------------
    
    # Write syslog, if configured
    if [[ ${LOG_SYSLOG} -eq 1 ]]; then

        # Get syslog tag
        local syslog_tag="${LOG_SYSLOG_TAG:-$(basename "${0}")}";
        # Get syslog facility
        local syslog_facility="${LOG_SYSLOG_FACILITY:-local0}";
        # Get pid of the calling process
        local syslog_pid="${$}"
        # Compose syslog message
        local syslog_msg="${level_upper}: ${msg}";

        # Log message to the syslog (log exception on error)
        logger                                        \
            --id="${syslog_pid}"                      \
            -t   "${syslog_tag}"                      \
            -p   "${syslog_facility}.${log_severity}" \
            "${syslog_msg}"                           \
        || _log_exception \
            "logger --id=\"${pid}\" -t \"${tag}\" -p \"${facility}.${log_severity}\" \"${syslog_msg}\""
            
    fi

    # --------------------- Log file ---------------------
  
    # Write log to file, if configured
    if [ "${LOG_FILE}" != "" ]; then

        local log_file_msg=''

        # Place time at the beggining of the log
        log_file_msg+="[${date}]"
        # Append log level info
        file_line+="[${level_upper}";
        # Place context info, if configured
        [[ -n ${context:-} ]] && log_file_msg+="|${context}] " || log_file_msg+="] "
        # Append message
        log_file_msg+="${msg}"

        # Print message to the file (log error, on failure)
        echo -e                                \
            "${log_file_msg}" >> "${LOG_FILE}" \
        || _log_exception                      \
            "echo -e \"${log_file_msg}\" >> \"${LOG_FILE}\"";
            
    fi;

    # --------------------- JSON log ---------------------

    # Write log to file, if configured
    if [ "${LOG_JSON_FILE}" != "" ]; then

        # Define format of the JSON log
        local log_json_msg_format='{ "timestamp" : "%s", "level" : "%s", "message" : "%s" }'
        # Compile JSON log
        local log_json_msg="$(printf "$log_json_msg_format" "${date_s_since_epoch}" "${level}" "${msg}")";
        
        # Print message to the file (log error, on failure)
        echo -e                                     \
            "${log_json_msg}" >> "${LOG_JSON_FILE}" \
        || _log_exception                           \
            "echo -e \"${log_json_msg}\" >> \"${LOG_JSON_FILE}\"";
            
    fi;

    # ------------------- Console log --------------------
    
    # If log level too high, return
    if [[ $log_severity -gt $LOG_LEVEL ]]; then
        return
    fi
    
    # Prepare colours
    local default_colour="${LOG_COLOURS[DEFAULT]}";
    local colour="${LOG_COLOURS[${level_upper}]:-${LOG_COLOURS[DEFAULT]}}";
    
    # Prepare message to be composed
    local log_msg=''
    
    # Compose message depending on the colout scheme
    if [[ LOG_COLOUR_WHOLE -eq 1 ]]; then

        # Change shell colour
        log_msg+="${colour}";
        # Place time at the beggining of the log, if configured
        [[ LOG_TIME -eq 1 ]] && log_msg+="[${date}]"
        # Append log level info
        log_msg+="[${level_upper}";
        # Place context info, if configured
        [[ -n ${context:-} ]] && log_msg+="|${context}] " || log_msg+="] "
        # Append message
        log_msg+="${msg}"
        # Reset shell colour
        log_msg+="${default_colour}";

    else

        # Place time at the beggining of the log, if configured
        [[ LOG_TIME -eq 1 ]] && log_msg+="[${colour}${date}${default_colour}]"
        # Append log level info
        log_msg+="[${colour}${level_upper}${default_colour}";
        # Place context info, if configured
        [[ -n ${context:-} ]] && log_msg+="|${colour}${context}${default_colour}] " || log_msg+="] "
        # Append message
        log_msg+="${msg}"
        
    fi

    # Print log
    case "${level}" in
        # Print DEBUG/INFO/WARNING log to stdout
        'debug'|'info'|'warn') echo -e "${log_msg}";;
        # Print ERRR log to stdout
        'error') echo -e "${log_msg}" >&2;;
        # Print erro  log, if not-implemented log level requested
        *) log 'error' "Undefined log level trying to log: ${@}";;
    esac
    
}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Prints debug log to the stdout
#
# @param context (optional)
#    context of the log message
# @param msg
#    message to be printed
#
# @see log
# -------------------------------------------------------------------
log_debug() {
    log debug "${@}"
}

# -------------------------------------------------------------------
# @brief Prints info log to the stdout
#
# @param context (optional)
#    context of the log message
# @param msg
#    message to be printed
#
# @see log
# -------------------------------------------------------------------
log_info() {
    log info "${@}"
}

# -------------------------------------------------------------------
# @brief Prints warn log to the stdout
#
# @param context (optional)
#    context of the log message
# @param msg
#    message to be printed
#
# @see log
# -------------------------------------------------------------------
log_warn() {
    log warn "${@}"
}

# -------------------------------------------------------------------
# @brief Prints error log to the stdout
#
# @param context (optional)
#    context of the log message
# @param msg
#    message to be printed
#
# @see log
# -------------------------------------------------------------------
log_error() {
    log error "${@}"
}
