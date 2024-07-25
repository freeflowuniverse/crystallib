#!/bin/bash
set -eux -o pipefail

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is intended to run on macOS only."
    exit 1
fi


export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

brew install lima sshpass
grep -qxF "alias nerdctl='limactl shell default nerdctl'" ~/.zprofile || echo "alias nerdctl='limactl shell default nerdctl'" >> ~/.zprofile

limactl delete -f default

limactl create --name default --tty=false templates/default.yaml

limactl start default


lima nerdctl run --rm hello-world

limactl list

echo "LIMA OK"

limactl shell default

