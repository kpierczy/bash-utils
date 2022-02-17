# ====================================================================================================================================
# @file     docker.bash
# @author   Krzysztof Pierczyk (krzysztof.pierczyk@gmail.com)
# @date     Tuesday, 26th October 2021 12:31:34 pm
# @modified Thursday, 17th February 2022 11:59:25 am
# @project  bash-utils
# @brief
#    
#    Sourcing this script provides user's terminal with handy docker-related commands
#    
# @copyright Krzysztof Pierczyk © 2021
# ====================================================================================================================================

# ========================================================== Configuration ========================================================= #

# Standard docker arguments
DOCKER_STD_ARGS=(
    -it
    --rm
    --network=host
    --ipc=host
)

# ============================================================ Functions =========================================================== #

# -------------------------------------------------------------------
# @brief Runs the docker container with standard arguments
#
# @returns 
#    @c 0 if container was run succesfully \n
#    @c 1 if either no argument was given and @var DEFULT_DOCKER_IMG
#       is not set, or container failed to run
#
# @options
#
#    -c|--container  name of the container to be run; if no container
#                    given, the @var DEFULT_DOCKER_IMG container is 
#                    run
#
# @environment 
# 
#    DEFULT_DOCKER_IMG - default docker container to be run
#
# -------------------------------------------------------------------
function drun() { 

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-c|--container',container
    )
    
    # Parse arguments to a named array
    parse_options_s
    
    # -------------------------------------------------

    # Arguments
    local container_name_=${options[container]:-$DEFULT_DOCKER_IMG}

    # Check if container is defined
    if ! is_var_set container_name_; then
        log_error "docker" "No container to be run given"
        return 1
    fi

    # Run the specified container
    sudo docker run $DOCKER_STD_ARGS $container_name_
}

# -------------------------------------------------------------------
# @brief Runs the docker container with standard arguments and 
#    additional volume mounted
#
# @returns 
#    @c 0 if container was run succesfully \n
#    @c 1 if either no argument was given and @var DEFULT_DOCKER_IMG
#       is not set, or container failed to run
#
# @options
#
#    -c|--container  name of the container to be run; if no container
#                    given, the @var DEFULT_DOCKER_IMG container is 
#                    run
#
# @environment 
# 
#    DEFULT_DOCKER_IMG - default docker container to be run
#
# -------------------------------------------------------------------
function drunv() { 

    # ---------------- Parse arguments ----------------

    # Function's options
    local -a opt_definitions=(
        '-c|--container',container
    )
    
    # Parse arguments to a named array
    parse_options_s
    
    # -------------------------------------------------

    # Arguments
    local container_name_=${options[container]:-$DEFULT_DOCKER_IMG}

    # Check if container is defined
    if ! is_var_set container_name_; then
        log_error "docker" "No container to be run given"
        return 1
    fi

    # Run the specified container
    sudo docker run $DOCKER_STD_ARGS -v $container_name_
}

# ============================================================= Aliases ============================================================ #

# -------------------------------------------------------------------
# @brief Shortcut for 'sudo docker ps' (lists docker processes)
# -------------------------------------------------------------------
alias dps='sudo docker ps'

# -------------------------------------------------------------------
# @brief Stops and removes all docker containers
# -------------------------------------------------------------------
alias drm='                                                  \
    if [[ $(sudo docker ps -a -q) != "" ]] > /dev/null; then \
        sudo docker stop $(sudo docker ps -a -q) &&          \
        sudo docker rm $(sudo docker ps -a -q);              \
    fi'

# -------------------------------------------------------------------
# @brief Stops and removes all docker containers; prunes 
#    intermediate images
# -------------------------------------------------------------------
alias prune='                                                \
    if [[ $(sudo docker ps -a -q) != "" ]] > /dev/null; then \
        sudo docker stop $(sudo docker ps -a -q) &&          \
        sudo docker rm $(sudo docker ps -a -q);              \
    fi && sudo docker image prune'


# -------------------------------------------------------------------
# @brief Shortcut for 'sudo docker images' (lists docker images)
# -------------------------------------------------------------------
alias dimg='sudo docker images'

# -------------------------------------------------------------------
# @brief Shortcut for 'sudo docker rmi' (removes a docker image)
# -------------------------------------------------------------------
alias dimgrm='sudo docker rmi'

# # -------------------------------------------------------------------
# # @brief Starts an additional bash in the running container
# # -------------------------------------------------------------------
# if [[ $DEFULT_DOCKER_IMG != "" ]]; then
#     alias dexec="sudo docker exec -it $(sudo docker ps | awk -v i=$DEFULT_DOCKER_IMG '/i/ {print $1}') bash"
# else
#     alias dexec="sudo docker exec -it $(sudo docker ps | awk '/ros/ {print $1}') bash"
# fi
