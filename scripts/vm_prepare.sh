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
            echo env not found, downloading from $download_url
            myapt curl
            if curl -o "$script_name" -s $download_url; then
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

set -ex

sourceenv

if [[ "$1" = "reset" ]]; then
    rm -f "$HOME/.vmodules/done_zinit"
    rm -rf /etc/zinit
fi

if ! [[ -f "$HOME/.vmodules/done_zinit" ]]; then
    myexec "v_install_zinit.sh" "https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/v_install_zinit.sh"
    touch "$HOME/.vmodules/done_zinit"
fi

mkdir -p /etc/zinit/cmds

##################### STARTUP SCRIPTS #############################

#configure the redis in zinit
function zinit_configure_hero {
    myreset    
    cmd="
#!/bin/bash
set -ex
source ~/env.sh
crystal_install
"
    zinitcmd="
after:
  - redis
"
    zinitinstall "crystalinstall" -oneshot
}

zinit_configure_hero

if pgrep zinit >/dev/null; then
    # If running, kill Redis server
    echo "zinit is running. Stopping..."
    pkill zinit
    echo "zinit server has been stopped."
else
    echo "zinit server is not running."
fi

zinit init &