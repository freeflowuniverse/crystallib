#!/bin/bash

set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi

function myapt {
    apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
}

function sourceenv() {
    local script_name=~/env.sh
    local download_url="https://raw.githubusercontent.com/freeflowuniverse/crystallib/${CLBRANCH}/scripts/env.sh"    
    
    if [ -f "$script_name" ]; then
        echo "env.sh exists "
    else
        if [ -f "env.sh" ]; then
            cp env.sh ~/env.sh
        else
            echo "env not found, downloading from '$download_url'..."
            myapt curl
            exit 1
            if curl -o "$script_name" -s "$download_url"; then
                echo "Download successful. Script '$script_name' is now available in the current directory."
            else
                echo "Error: Download failed. Script '$script_name' could not be downloaded."
                exit 1
            fi
        fi
    fi
    source $script_name

}

##################### ABOVE IS STD FOR ALL SCRIPTS #############################

set -e

sourceenv
myexec "vm_prepare.sh" "https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/vm_prepare.sh"

##################### STARTUP SCRIPTS #############################

#### ollama main

cmd="
#!/bin/bash
set -ex
source ~/env.sh
myapt cuda-command-line-tools-12-2 
myapt cuda-nvcc-12-2
myapt lshw
nvcc --version
if ! [ -x "$(command -v ollama)" ]; then
curl https://ollama.ai/install.sh | sh
fi
ollama serve
"
zinitcmd="
after:
  - crystalinstall
"
zinitinstall "ollama"  

cmd="
#!/bin/bash
set -ex
source ~/env.sh
ollama pull mystral
"
zinitcmd="
after:
  - ollama
"
zinitinstall "ollama" -oneshot

#### zinit restart

if pgrep zinit >/dev/null; then
    # If running, kill Redis server
    echo "zinit is running. Stopping..."
    pkill zinit
    echo "zinit server has been stopped."
else
    echo "zinit server is not running."
fi

zinit init &