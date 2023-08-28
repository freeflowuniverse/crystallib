#!/usr/bin/env bash
set -ex
cd ~/code/github/freeflowuniverse/crystallib
SOURCE=${BASH_SOURCE[0]}
DIR_OF_THIS_SCRIPT="$( dirname "$SOURCE" )"
ABS_DIR_OF_SCRIPT="$( realpath $DIR_OF_THIS_SCRIPT )"
mkdir -p ~/.vmodules/freeflowuniverse
unlink ~/.vmodules/freeflowuniverse/crystallib
ln -s $ABS_DIR_OF_SCRIPT/crystallib ~/.vmodules/freeflowuniverse/crystallib
v ${ABS_DIR_OF_SCRIPT}/cmd/crystallib.v
rm -f /usr/local/bin/crystallib
ln -s ${ABS_DIR_OF_SCRIPT}/cmd/crystallib /usr/local/bin/crystallib
# bash doc.sh
