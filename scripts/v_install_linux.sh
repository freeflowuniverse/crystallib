#!/bin/bash

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

function github_keyscan {
    mkdir -p ~/.ssh
    if ! grep github.com ~/.ssh/known_hosts > /dev/null
    then
        ssh-keyscan github.com >> ~/.ssh/known_hosts
    fi
}

function os_package_install {
    apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
}

os_package_install "curl"

rm -f /tmp/v_install.sh
set +e
curl -k https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install.sh > /tmp/v_install.sh
if [ $? -eq 0 ]; then
    echo "Error: Unable to download the v_install script."
    echo "source location was:  https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install.sh"
    exit 1
fi
rm -f /usr/local/bin/zinit
curl https://github.com/freeflowuniverse/freeflow_binary/raw/main/x86_64/zinit /usr/local/bin/zinit

file_url="https://github.com/freeflowuniverse/freeflow_binary/raw/main/x86_64/zinit"
destination_dir="/usr/local/bin"
destination_path="$destination_dir/zinit"
min_file_size=$((5*1024*1024))

curl -o "$destination_path" -L "$file_url"
if [ $? -eq 0 ]; then
    file_size=$(stat -c%s "$destination_path")
    if [ "$file_size" -gt "$min_file_size" ]; then
        echo "Downloaded file is larger than 5MB."
        echo "Moving the file to $destination_dir."
        sudo mv "$destination_path" "$destination_dir/"
        if [ $? -eq 0 ]; then
            echo "File moved successfully."
        else
            echo "Error: Unable to move the file."
            exit 1
        fi
    else
        echo "Downloaded file is not larger than 5MB."
        exit 1
    fi
else
    echo "Error: Unable to download the file."
    exit 1
fi

set -e

mkdir -p 