set -ex
cd ~/code/github/freeflowuniverse/crystallib/cli/hero
bash compile.sh

hero git_get https://github.com/freeflowuniverse/freeflow_binary.git

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

mkdir -p ~/code/github/freeflowuniverse/freeflow_binary/$ASSET
cp ~/Downloads/hero ~/code/github/freeflowuniverse/freeflow_binary/$ASSET/

hero git_do -f freeflow_binary -cpp -m "new release hero" -script

