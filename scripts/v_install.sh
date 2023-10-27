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
        rm -f $HOME/.env.sh
        if [[ -h "$HOME/env.sh" ]] || [[ -L "$HOME/env.sh" ]]; then
            echo 
        else   
            rm -f $HOME/env.sh        
            ln -s $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh $HOME/env.sh
        fi
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
}

##################### ABOVE IS STD FOR ALL SCRIPTS #############################

set -e

sourceenv

if [[ "$1" = "reset" ]]; then
    myreset
fi

crystal_install

echo "v and crystallib installed"
