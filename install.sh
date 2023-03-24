#!/usr/bin/env bash
set -ex
SOURCE=${BASH_SOURCE[0]}
DIR_OF_THIS_SCRIPT="$( dirname "$SOURCE" )"
ABS_DIR_OF_SCRIPT="$( realpath $DIR_OF_THIS_SCRIPT )"
mkdir -p ~/.vmodules/freeflowuniverse
ln -s $ABS_DIR_OF_SCRIPT/ ~/.vmodules/freeflowuniverse/crystallib