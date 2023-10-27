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

rm -f /tmp/v_install.sh
set +e
curl -k https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install.sh > /tmp/v_install.sh
if [ $? -eq 0 ]; then
    echo "v install downloaded"
else
    echo "Error: Unable to download the v_install script."
    echo "source location was:  https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install.sh"
    exit 1
fi
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

#!/bin/bash


start1="#!/bin/bash
exec: redis-server --port 7777
test: redis-cli -p 7777 PING
after:
  - redis-init
"
echo "$start1" > "/etc/zinit/redis-server"
