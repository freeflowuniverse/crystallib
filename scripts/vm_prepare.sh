#!/bin/bash

set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi

function mycmdinstall {
    local command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        echo
    else    
        myapt '$command_name'
    fi
}

function sourceenv() {
    local script_name=~/env.sh
    local download_url="https://raw.githubusercontent.com/freeflowuniverse/crystallib/${CLBRANCH}/scripts/env.sh"    

    if [[ -f "${HOME}/code/github/freeflowuniverse/crystallib/scripts/env.sh" ]]; then
        cp ~/code/github/freeflowuniverse/crystallib/scripts/env.sh ~/env.sh
    else
        mycmdinstall curl
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

set -ex

sourceenv

if [[ "$1" = "reset" ]]; then
    rm -f "$HOME/.vmodules/done_zinit"
    rm -rf /etc/zinit
fi

if ! [[ -f "$HOME/.vmodules/done_zinit" ]]; then
    bootstrap "v_install_zinit.sh" "https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install_zinit.sh"
    touch "$HOME/.vmodules/done_zinit"
fi

mkdir -p /etc/zinit/cmds

##################### STARTUP SCRIPTS #############################

#configure the redis in zinit
function zinit_configure_vm {
    myreset    
    cmd="
#!/bin/bash
set -e
source ~/env.sh
crystal_install
"
    zinitinstall "crystalinstall" -oneshot
}

zinit_configure_redis
zinit_configure_vm

# zinit monitor crystalinstall

if pgrep zinit >/dev/null; then
    # If running, kill Redis server
    echo "zinit is running. Stopping..."
    pkill zinit
    echo "zinit server has been stopped."
else
    echo "zinit server is not running."
fi
zinit init &