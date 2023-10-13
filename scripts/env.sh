#!/usr/bin/env bash
# set -x

if [[ -z "${CLBRANCH}" ]]; then 
    # echo " - DEFAULT BRANCH FOR CRYSTALLIB SET"
    export CLBRANCH="development"
fi

export OURHOME="$HOME"

if [ -z "$TERM" ]; then
    export TERM=xterm
fi

export DIR_BASE="$HOME/play"
export DIR_BUILD="/tmp"
export DIR_CODE="$OURHOME/code"
export DIR_CODEWIKI="$OURHOME/codewiki"
export DIR_CODE_INT="$OURHOME/_code"
export DIR_BIN="$DIR_BASE/bin"
export DIR_SCRIPTS="$DIR_BASE/bin"

mkdir -p $DIR_BASE
mkdir -p $DIR_CODE
mkdir -p $DIR_CODE_INT
mkdir -p $DIR_BUILD
mkdir -p $DIR_BIN
mkdir -p $DIR_SCRIPTS

git config --global pull.rebase false


# if [[ -d "/workspace/crystaltools" ]]
# then
#     #this means we are booting in gitpod from crystal tools itself
#     export DIR_CT="/workspace/crystaltools"
# else    
#     export DIR_CT="$DIR_CODE/github/freeflowuniverse/crystaltools"
#     #get the crystal tools
#     crystal_tools_get
# fi

export PATH=$DIR_BIN:$DIR_SCRIPTS:$PATH