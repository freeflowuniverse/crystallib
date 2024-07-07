#!/bin/bash

export DEFAULT_NAME="c1"
export DEFAULT_IMAGE="ubuntu:24.04"
#export DEFAULT_PLATFORM="linux/amd64"
export DEFAULT_PLATFORM="linux/arm64"
export DEFAULT_PORTPREFIX="5"


function heroc_start() {
    set -x
    local container_name="${1:-$DEFAULT_NAME}"
    local portprefix="${2:-$DEFAULT_PORTPREFIX}"
    local docker_image="${3:-$DEFAULT_IMAGE}"
    local platform="${4:-$DEFAULT_PLATFORM}"
    
    local sshport=${portprefix}022
    local psqlport=${portprefix}432

    local portprefix

    # Validate the platform
    if [[ "$platform" != "linux/amd64" && "$platform" != "linux/arm64" ]]; then
        echo "Error: Unsupported platform '$platform'. Only 'linux/amd64' and 'linux/arm64' are supported."
        return 1
    fi

    # Check if the specified container already exists
    if nerdctl ps -a | grep -qw "$container_name"; then
        echo "Container '$container_name' already exists."
        # Ensure the container is running, if it was stopped
        if ! nerdctl ps --filter "name=$container_name" --filter "status=running" | grep -qw "$container_name"; then
            echo "Starting the '$container_name' container..."
            nerdctl start "$container_name"
        fi
    else
        echo "Creating and starting the container..."
        set -x
        nerdctl run --platform "$platform" -d --privileged --name "$container_name" -p 127.0.0.1:$psqlport:5432 -p 127.0.0.1:$sshport:22 --memory 1000m "$docker_image" bash -c "while true; do sleep 1000; done"
        # nerdctl run --platform "$platform" -d --privileged --name "$container_name" \
        #             --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
        #             --volume /sys/fs/cgroup:/sys/fs/cgroup:ro "$docker_image" \
        #             /lib/systemd/systemd
    fi
}

#examples for systemd
#nerdctl run --platform linux/amd64 -it --privileged --name c1 --cgroupns=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock --volume /sys/fs/cgroup:/sys/fs/cgroup:ro jrei/systemd-ubuntu /bin/bash
#nerdctl run --platform linux/amd64 -it --privileged --name c1 --cgroupns=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock jrei/systemd-ubuntu /bin/bash
#nerdctl run --platform linux/amd64 -it --privileged --name c1 -v /sys/fs/cgroup:/sys/fs/cgroup:ro jrei/systemd-ubuntu
#-v /sys/fs/cgroup:/sys/fs/cgroup:ro

function heroc_stop() {
    local container_name="${1:-$DEFAULT_NAME}"

    # Check if the specified container exists
    if nerdctl ps -a | grep -qw "$container_name"; then
        echo "Stopping container '$container_name'..."
        nerdctl stop "$container_name"
    # else
    #     echo "Container '$container_name' does not exist."
    fi
}

function heroc_delete() {
    local container_name="${1:-$DEFAULT_NAME}"
    heroc_stop $container_name
    # Check if the specified container exists
    if nerdctl ps -a | grep -qw "$container_name"; then
        echo "Deleting container '$container_name'..."
        nerdctl rm "$container_name"
    # else
    #     echo "Container '$container_name' does not exist."
    fi
}

function heroc_exec() {
    local container_name="${1:-$DEFAULT_NAME}"
    local command="$2"

    # Ensure container is running
    start_container "$container_name"

    # Execute command inside the container
    echo "Executing command inside '$container_name': $command"
    nerdctl exec -it "$container_name" /bin/sh -c "$command"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Command failed with status $status."
        return $status
    fi
}

function heroc_shell() {
    local container_name="${1:-$DEFAULT_NAME}"

    # Ensure container is running
    start_container "$container_name"

    # Get a shell inside the container
    echo "Opening shell inside '$container_name'..."
    nerdctl exec -it "$container_name" /bin/bash
}


function heroc_exec_script() {
    local container_name="${1:-$DEFAULT_NAME}"
    local script_name="$2"
    export MYPATH=$(dirname "$(realpath "$0")")
    local script_path="$MYPATH/$script_name"

    # Check if the script exists
    if [ ! -f "$script_path" ]; then
        echo "Script $script_path not found!"
        return 1
    fi

    # Copy the script to the container
    nerdctl cp "$script_path" "${container_name}:/tmp/$script_name"

    # Execute the script inside the container
    nerdctl exec -it "$container_name" bash -c "chmod +x /tmp/$script_name && /tmp/$script_name"
}

#start_container "vm1" "jrei/systemd-ubuntu" "linux/amd64"
# execute_command "vm1" "echo hello"
#get_shell "vm1"
# stop_container "vm1"
# delete_container "vm1"
