set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi

export DEBIAN_FRONTEND=noninteractive

export OURHOME="$HOME"
export DIR_CODE="$OURHOME/code"
export OURHOME="$HOME/play"
mkdir -p $OURHOME

if [ -z "$TERM" ]; then
    export TERM=xterm
fi

#!/bin/bash

# Check if the /etc/os-release file exists
if [ -e /etc/os-release ]; then
    # Read the ID field from the /etc/os-release file
    os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2)
    
    # Check if the ID is "ubuntu" (case-insensitive)
    if [ "${os_id,,}" == "ubuntu" ]; then
        echo "This system is running Ubuntu."
    else
        echo "This system is not running Ubuntu."
        exit 1
    fi
else
    echo "The /etc/os-release file does not exist. Unable to determine the operating system."
    exit 1
fi


function os_package_install {
    apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
}

os_package_install "tmux"

rm -f /tmp/v_install.sh

curl -k https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install.sh > /tmp/v_install.sh

#!/bin/bash

# Kill all existing tmux sessions
tmux list-sessions | cut -d: -f1 | xargs -I {} tmux kill-session -t {}

# Create a new tmux session and execute a command
tmux new-session -d -s mysession '/bin/bash /tmp/v_install.sh'

# Attach to the new session (optional)
tmux attach-session -t mysession
