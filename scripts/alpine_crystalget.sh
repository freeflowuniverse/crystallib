#!/bin/bash
set -ex

#will link users code to the home code
source_dir="/Users/${USER}/code"
target_dir="${HOME}/code"
if [ ! -e "$target_dir" ]; then
    if [ -d "$source_dir" ]; then
            ln -s "$source_dir" "$target_dir"
    fi
fi
CLBRANCH="development"
script_name=~/env.sh
download_url="https://raw.githubusercontent.com/freeflowuniverse/crystallib/${CLBRANCH}/scripts/env.sh"    
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

