#!/bin/bash

set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi

function package_check_install {
    local command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        echo
    else    
        package_install '$command_name'
    fi
}

function sourceenv() {
    local script_name=~/env.sh
    local download_url="https://raw.githubusercontent.com/freeflowuniverse/crystallib/${CLBRANCH}/scripts/env.sh"    

    if [[ -f "${HOME}/code/github/freeflowuniverse/crystallib/scripts/env.sh" ]]; then
        cp ~/code/github/freeflowuniverse/crystallib/scripts/env.sh ~/env.sh
    else
        package_check_install curl
        if curl -o "$script_name" -s $download_url; then
            echo "Download successful. Script '$script_name' is now available in the current directory."
        else
            echo "Error: Download failed. Script '$script_name' could not be downloaded."
            exit 1
        fi
    fi
    source $script_name
    exit 0
}

##################### ABOVE IS STD FOR ALL SCRIPTS #############################


sourceenv
bootstrap "vm_prepare.sh" "https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/vm_prepare.sh"

echo "VM PREPARE DONE"


##################### STARTUP SCRIPTS #############################

set -ex

echo "OLLAMA CONFIG"

#### ollama main
X=""
if ! [ -x "$(command -v ollama)" ]; then
curl https://ollama.ai/install.sh | sh
fi
package_install cuda-command-line-tools-12-2 
package_install cuda-nvcc-12-2
package_install lshw
nvcc --version


unset cmd
zinitcmd="
exec: ollama serve
"
zinitinstall "ollama"  

cmd="
#!/bin/bash
set -ex
source ~/env.sh
ollama pull mistral
"
zinitcmd="
after:
  - ollama
"
zinitinstall "ollamapull" -oneshot

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

echo "OLLAMA IN INIT"