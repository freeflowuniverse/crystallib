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

# Check if the processor architecture is 64-bit
if [ "$(uname -m)" == "x86_64" ]; then
    echo "This system is running a 64-bit processor."
else
    echo "This system is not running a 64-bit processor."
    exit 1
fi


function os_package_install {
    apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
}

rm -f /tmp/v_install.sh

curl -k https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install.sh > /tmp/v_install.sh

#!/bin/bash
