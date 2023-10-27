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
    script_name=~/env.sh
    download_url="https://raw.githubusercontent.com/freeflowuniverse/crystallib/${CLBRANCH}/scripts/env.sh"    

    if [ -f "${HOME}/code/github/freeflowuniverse/crystallib/scripts/env.sh" ]; then
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
}

##################### ABOVE IS STD FOR ALL SCRIPTS #############################

set -ex

sourceenv

if [[ "$1" = "reset" ]]; then
    myreset
fi

crystal_install
