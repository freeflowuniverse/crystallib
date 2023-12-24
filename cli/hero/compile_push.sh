set -e
cd ~/code/github/freeflowuniverse/crystallib/cli/hero
bash compile_debug.sh

hero git pull -u https://github.com/freeflowuniverse/freeflow_binary.git

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ASSET="linux"
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

mkdir -p ~/code/github/freeflowuniverse/freeflow_binary/$ASSET
cp $HEROPATH ~/code/github/freeflowuniverse/freeflow_binary/$ASSET/

hero git push -f freeflow_binary -m "new release hero" -script

echo " ** HERO COMPILE PUSH OK"

