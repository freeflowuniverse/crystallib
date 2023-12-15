#!/bin/bash

# checks os and architecture for correct release
# https://stackoverflow.com/a/8597411 
echo "Installing hero..."

RELEASES="https://github.com/freeflowuniverse/freeflow_binary/raw/main"
ASSET=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ASSET="linux"
    echo "Linux binary not yet available :(."
    echo "Try compiling hero yourself by running compile.sh in crystallib/baobab/hero/executor"
    exit 1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ASSET="osx"
fi
if [[ "$(uname -m)" == "x86_64"* ]]; then
    ASSET="${ASSET}_x64"
elif [[ "$(uname -m)" == "arm64"* ]]; then
    ASSET="${ASSET}_arm"
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export HEROPATH='/usr/local/bin/hero'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/hero
fi


ASSET="${ASSET}/hero"
echo "${RELEASES}/${ASSET}"
curl -sLO "${RELEASES}/${ASSET}"
chmod +x hero
mv hero $HEROPATH

$HEROPATH init

echo "Successfully installed hero on $HEROPATH!"
