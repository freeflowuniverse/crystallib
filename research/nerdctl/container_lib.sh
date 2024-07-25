#!/bin/bash

export DEFAULT_NAME="c1"
export DEFAULT_IMAGE="ubuntu:24.04"
#export DEFAULT_PLATFORM="linux/amd64"
export DEFAULT_PLATFORM="linux/arm64"
export DEFAULT_PORTPREFIX="5"


function heroc_start() {
    set -ux -o pipefail
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
        set -ex
        #needs to be in the vm
        limactl shell default mkdir -p /tmp/aptcache
        nerdctl run --platform "$platform" -d --privileged --name "$container_name" \
            -p 127.0.0.1:$psqlport:5432 -p 127.0.0.1:$sshport:22 --memory 1000m \
            --mount type=bind,src=/tmp/aptcache,dst=/var/cache/apt/archives \
            --hostname "$container_name" \
            "$docker_image" bash -c "while true; do sleep 1000; done"
        
        ssh-keygen -R \[127.0.0.1\]:$sshport
        heroc_exec_script ${container_name} install_ssh.sh
        authorize_ssh_key "${sshport}"
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
    heroc_start "$container_name"

    # Get a shell inside the container
    echo "Opening shell inside '$container_name'..."
    nerdctl exec -it "$container_name" /bin/bash
}


function heroc_exec_script() {
    # Ensure the function has two arguments: container name and script name
    if [ "$#" -lt 2 ]; then
        echo "Usage: heroc_exec_script_ssh <container_name> <script_name>"
        return 1
    fi    
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

function heroc_exec_script_ssh() {
    # Ensure the function has two arguments: container name and script name
    if [ "$#" -lt 3 ]; then
        echo "Usage: heroc_exec_script_ssh <container_name> <script_name> <sshport>"
        return 1
    fi
    local container_name="$1"
    local script_name="$2"
    local sshport="$3"
    local ssh_user="root"  # Default SSH user for the container
    export MYPATH=$(dirname "$(realpath "$0")")
    local script_path="$MYPATH/$script_name"

    # Ensure SSH agent forwarding, disable strict host key checking
    local ssh_options="-A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

    # Check if the script exists
    if [ ! -f "$script_path" ]; then
        echo "Script $script_path not found!"
        return 1
    fi

    # Copy the script to the container via SSH
    scp -P "$sshport" $ssh_options "$script_path" "$ssh_user@localhost:/tmp/$script_name"
    if [ $? -ne 0 ]; then
        echo "Failed to copy script to container!"
        return 1
    fi

    # Execute the script inside the container via SSH
    sshpass -p 'admin' ssh -p "$sshport" $ssh_options "$ssh_user@localhost" "chmod +x /tmp/$script_name && /tmp/$script_name"
    if [ $? -ne 0 ]; then
        echo "Failed to execute script inside container!"
        return 1
    fi

    echo "Script executed successfully inside the container."
}

#!/bin/bash

# Function to authorize SSH key on a remote server
authorize_ssh_key() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: authorize_ssh_key <sshport>"
        return 1
    fi    
    set -x

    local REMOTE_PORT=$1
    local REMOTE_USER="root"
    local REMOTE_HOST="localhost"
    local PASSWORD="admin"
    local TEMP_KEY_FILE="/tmp/sshkey"
    local ssh_options="-A -o StrictHostKeyChecking=no"
    rm -f "${TEMP_KEY_FILE}"

    # Function to display an error message and exit
    function error_exit {
        echo "ERROR"
        echo "$1" >&2
        return 1
    }

    # Check if ssh-agent is running and has keys loaded
    ssh-add -L > /dev/null 2>&1
    if [ $? -ne 0 ]; then
    error_exit "No keys are loaded in ssh-agent."
    return 1
    fi

    # Get the first loaded key
    KEY=$(ssh-add -L | head -n 1)
    if [ -z "$KEY" ]; then
        error_exit "No keys found in ssh-agent."
        return 1
    fi

    # Save the first key to a temporary file
    echo "$KEY" > "${TEMP_KEY_FILE}.pub"

    cat "${TEMP_KEY_FILE}.pub"
    
    # Check if ssh-copy-id and sshpass are installed
    if ! command -v ssh-copy-id &> /dev/null; then
        error_exit "ssh-copy-id could not be found. Please install it and try again."
        return 1
    fi

    if ! command -v sshpass &> /dev/null; then
        error_exit "sshpass could not be found. Please install it and try again."
        return 1
    fi

    # Copy the selected key to the remote server using sshpass
    ssh-keygen -R [localhost]:${REMOTE_PORT}
    sshpass -p "$PASSWORD" ssh -p "$REMOTE_PORT" $ssh_options "root@localhost" "ls /"
    sshpass -p "$PASSWORD" ssh-copy-id -f -i "$TEMP_KEY_FILE" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST"
    if [ $? -ne 0 ]; then
        #rm -f "$TEMP_KEY_FILE"
        error_exit "Failed to copy SSH key to the remote server."
        return 1
    fi

    # Clean up the temporary file
    #rm -f "$TEMP_KEY_FILE"

    echo "SSH key has been successfully authorized on the remote server."
}

# Example usage
# authorize_ssh_key "7022"

#start_container "vm1" "jrei/systemd-ubuntu" "linux/amd64"
# execute_command "vm1" "echo hello"
#get_shell "vm1"
# stop_container "vm1"
# delete_container "vm1"
