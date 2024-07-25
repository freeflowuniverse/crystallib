#!/bin/bash
set -ex

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y build-essential curl wget mc sudo

curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
bash /tmp/install.sh

#bash /root/code/github/freeflowuniverse/crystallib/install.sh

apt-get remove -y gcc
apt-get install -y libsqlite3-dev tcc

#with hero (will compile hero as well)
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/build_hero.sh > /tmp/build_hero.sh
bash /tmp/build_hero.sh


echo "CRYSTAL INSTALLED."
