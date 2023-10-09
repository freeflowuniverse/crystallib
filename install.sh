#!/usr/bin/env bash
set -ex
cd ~/code/github/freeflowuniverse/crystallib
SOURCE=${BASH_SOURCE[0]}
DIR_OF_THIS_SCRIPT="$( dirname "$SOURCE" )"
ABS_DIR_OF_SCRIPT="$( realpath $DIR_OF_THIS_SCRIPT )"
mkdir -p ~/.vmodules/freeflowuniverse
rm -f ~/.vmodules/freeflowuniverse/crystallib
ln -s $ABS_DIR_OF_SCRIPT/src ~/.vmodules/freeflowuniverse/crystallib
bash doc.sh
