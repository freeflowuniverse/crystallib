#!/bin/bash

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is intended to run on macOS only."
    exit 1
fi

alias nerdctl='limactl shell default nerdctl'

export DEFAULT_NAME="c1"
export DEFAULT_IMAGE="ubuntu:24.04"
export DEFAULT_PLATFORM="linux/arm64"
export DEFAULT_PORTPREFIX="5"

function error_exit {
    echo "ERROR"
    echo "$1" >&2
    exit 1
}

function heroc_start() {
    set -euxo pipefail
    local container_name="${1:-$DEFAULT_NAME}"
    local portprefix="${2:-$DEFAULT_PORTPREFIX}"
    local docker_image="${3:-$DEFAULT_IMAGE}"
    local platform="${4:-$DEFAULT_PLATFORM}"
    
    local sshport=${portprefix}022
    local psqlport=${portprefix}432

    # Validate the platform
    if [[ "$platform" != "linux/amd64" && "$platform" != "linux/arm64" ]]; then
        error_exit "Unsupported platform '$platform'. Only 'linux/amd64' and 'linux/arm64' are supported."
    fi

    # Check if the specified container already exists
    if lima nerdctl ps -a | grep -qw "$container_name"; then
        echo "Container '$container_name' already exists."
        # Ensure the container is running, if it was stopped
        if ! lima nerdctl ps --filter "name=$container_name" --filter "status=running" | grep -qw "$container_name"; then
            echo "Starting the '$container_name' container..."
            lima nerdctl start "$container_name"
        fi
        heroc_exec_script "$container_name" install_ssh.sh
    else
        echo "Creating and starting the container..."
        set -ex
        mkdir -p $HOME/aptcache
        limactl shell default mkdir -p /aptcache
        lima nerdctl run --platform "$platform" -d --privileged --name "$container_name" \
            -p 127.0.0.1:$psqlport:5432 -p 127.0.0.1:$sshport:22 --memory 2000m \
            --mount type=bind,src=/code,dst=/root/code \
            --mount type=bind,src=/aptcache,dst=/var/cache/apt/archives \
            --hostname "$container_name" \
            "$docker_image" bash -c "while true; do sleep 1000; done"
            

        ssh-keygen -R \[127.0.0.1\]:$sshport
        heroc_exec_script "$container_name" install_ssh.sh
        if [ $? -ne 0 ]; then
            error_exit "Failed to execute script install_ssh.sh inside container ${container_name}!"
        fi        
        authorize_ssh_key "${sshport}"
        if [ $? -ne 0 ]; then
            error_exit "Failed to execute authorize_ssh_key!"
        fi        
    fi
}

function heroc_stop() {
    local container_name="${1:-$DEFAULT_NAME}"

    # Check if the specified container exists
    if lima nerdctl ps -a | grep -qw "$container_name"; then
        echo "Stopping container '$container_name'..."
        lima nerdctl stop "$container_name"
    fi
}

function heroc_delete() {
    local container_name="${1:-$DEFAULT_NAME}"
    heroc_stop "$container_name"
    # Check if the specified container exists
    if lima nerdctl ps -a | grep -qw "$container_name"; then
        echo "Deleting container '$container_name'..."
        lima nerdctl rm "$container_name"
    fi
}

function heroc_exec() {
    local container_name="${1:-$DEFAULT_NAME}"
    local command="$2"

    # Ensure container is running
    heroc_start "$container_name"

    # Execute command inside the container
    echo "Executing command inside '$container_name': $command"
    set +e
    lima nerdctl exec -it "$container_name" /bin/sh -c "$command"
    local status=$?
    if [ $status -ne 0 ]; then
        error_exit "Command failed with status $status."
    fi
    set -e
}

function heroc_shell() {
    local container_name="${1:-$DEFAULT_NAME}"

    # Ensure container is running
    heroc_start "$container_name"

    # Get a shell inside the container
    echo "Opening shell inside '$container_name'..."
    lima nerdctl exec -it "$container_name" /bin/bash
}

function heroc_exec_script() {
    # Ensure the function has two arguments: container name and script name
    if [ "$#" -lt 2 ]; then
        error_exit "Usage: heroc_exec_script <container_name> <script_name>"
    fi    
    local container_name="${1:-$DEFAULT_NAME}"
    local script_name="$2"
    export MYPATH=$(dirname "$(realpath "$0")")
    local script_path="${MYPATH}/scripts/${script_name}"

    # Check if the script exists
    set +e
    if [ ! -f "$script_path" ]; then
        error_exit "Script $script_path not found!"
    fi

    # Copy the script to the container
    lima nerdctl cp "$script_path" "${container_name}:/tmp/$script_name"
    if [ $? -ne 0 ]; then
        error_exit "Could not copy $script_path to container!"
    fi

    # Execute the script inside the container
    lima nerdctl exec -it "$container_name" bash -c "chmod +x /tmp/$script_name && /tmp/$script_name"
    if [ $? -ne 0 ]; then
        error_exit "Could not execute $script_path in container ${container_name}!"
    fi
    set -e
}

function heroc_exec_script_ssh() {
    # Ensure the function has two arguments: container name and script name
    if [ "$#" -lt 3 ]; then
        error_exit "Usage: heroc_exec_script_ssh <container_name> <script_name> <sshport>"
    fi
    local container_name="$1"
    local script_name="$2"
    local sshport="$3"
    local ssh_user="root"  # Default SSH user for the container
    export MYPATH=$(dirname "$(realpath "$0")")
    local script_path="$MYPATH/scripts/$script_name"

    # Ensure SSH agent forwarding, disable strict host key checking
    local ssh_options="-A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

    # Check if the script exists
    if [ ! -f "$script_path" ]; then
        error_exit "Script $script_path not found!"
    fi
    set +e
    # Copy the script to the container via SSH
    scp -P "$sshport" $ssh_options "$script_path" "$ssh_user@localhost:/tmp/$script_name"
    if [ $? -ne 0 ]; then
        error_exit "Failed to copy script to container!"
    fi

    # Execute the script inside the container via SSH
    sshpass -p 'admin' ssh -p "$sshport" $ssh_options "$ssh_user@localhost" "chmod +x /tmp/$script_name && /tmp/$script_name"
    if [ $? -ne 0 ]; then
        error_exit "Failed to execute script inside container!"
    fi
    set -e
    echo "Script executed successfully inside the container."
}

# Function to authorize SSH key on a remote server
authorize_ssh_key() {
    if [ "$#" -lt 1 ]; then
        error_exit "Usage: authorize_ssh_key <sshport>"
    fi    
    set -x
    set +e

    local REMOTE_PORT=$1
    local REMOTE_USER="root"
    local REMOTE_HOST="localhost"
    local PASSWORD="admin"
    local TEMP_KEY_FILE="/tmp/sshkey"
    local ssh_options="-A -o StrictHostKeyChecking=no"
    rm -f "${TEMP_KEY_FILE}"

    # Check if ssh-agent is running and has keys loaded
    ssh-add -L > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error_exit "No keys are loaded in ssh-agent."
    fi

    # Get the first loaded key
    KEY=$(ssh-add -L | head -n 1)
    if [ -z "$KEY" ]; then
        error_exit "No keys found in ssh-agent."
    fi

    # Save the first key to a temporary file
    echo "$KEY" > "${TEMP_KEY_FILE}.pub"
    cat "${TEMP_KEY_FILE}.pub"
    
    # Check if ssh-copy-id and sshpass are installed
    if ! command -v ssh-copy-id &> /dev/null; then
        error_exit "ssh-copy-id could not be found. Please install it and try again."
    fi

    if ! command -v sshpass &> /dev/null; then
        error_exit "sshpass could not be found. Please install it and try again."
    fi

    set -e

    # Copy the selected key to the remote server using sshpass
    ssh-keygen -R [localhost]:${REMOTE_PORT}
    sshpass -p "$PASSWORD" ssh -p "$REMOTE_PORT" $ssh_options "root@localhost" "ls /"
    sshpass -p "$PASSWORD" ssh-copy-id -f -i "$TEMP_KEY_FILE" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST"
        if [ $? -ne 0 ]; then
            #rm -f "$TEMP_KEY_FILE"
            error_exit "Failed to copy SSH key to the remote server."
        fi

    # Clean up the temporary file
    #rm -f "$TEMP_KEY_FILE"
    
    echo "SSH key has been successfully authorized on the remote server."
}
