#!/bin/bash

set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi

function os_package_install {
    apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
}

function sourceenv() {
    local script_name="env.sh"
    local download_url="https://raw.githubusercontent.com/freeflowuniverse/crystallib/${CLBRANCH}/scripts/env.sh"
    
    if [ -f "./$script_name" ]; then
        echo "Script '$script_name' already exists in the current directory."
    else
        echo "env not found, downloading from '$download_url'..."
        os_package_install curl
        exit 1
        if curl -o "./$script_name" -s "$download_url"; then
            echo "Download successful. Script '$script_name' is now available in the current directory."
            source env.sh
        else
            echo "Error: Download failed. Script '$script_name' could not be downloaded."
            exit 1
        fi
    fi
}


set +e

rm -f /usr/local/bin/zinit
curl https://github.com/freeflowuniverse/freeflow_binary/raw/main/x86_64/zinit /usr/local/bin/zinit

file_url="https://github.com/freeflowuniverse/freeflow_binary/raw/main/x86_64/zinit"
destination_dir="/usr/local/bin"
destination_tmp_path="/tmp/zinit0"
destination_path="$destination_dir/zinit"
min_file_size=$((5*1024*1024))

curl -o "$destination_tmp_path" -L "$file_url"
if [ $? -eq 0 ]; then
    file_size=$(stat -c%s "$destination_tmp_path")
    if [ "$file_size" -gt "$min_file_size" ]; then
        echo "Downloaded file is larger than 5MB."
        echo "Moving the file to $destination_path."
        rm -f destination_path
        sudo mv "$destination_tmp_path" "$destination_path"
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

chmod 770 $destination_path

set -e

mkdir -p /etc/zinit/

echo "zinit installed ok"