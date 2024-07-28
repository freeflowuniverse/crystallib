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

# Function to check if v-analyzer is installed and working
check_v_analyzer() {
    if [ -f "/root/.config/v-analyzer/bin/v-analyzer" ]; then
        version=$(/root/.config/v-analyzer/bin/v-analyzer --version 2>&1)
        if [ $? -eq 0 ] && [[ $version == v-analyzer* ]]; then
            return 0
        fi
    fi
    return 1
}

if check_v_analyzer; then
    echo "v-analyzer is already installed and working correctly."
else
    echo "v-analyzer is not installed or not working. Installing now..."    
    curl -fsSL https://raw.githubusercontent.com/vlang/v-analyzer/main/install.vsh > /tmp/v-analyzer-install.vsh
    chmod +x /tmp/v-analyzer-install.vsh
    /tmp/v-analyzer-install.vsh --no-interaction
    if check_v_analyzer; then
        echo "v-analyzer has been successfully installed."
    else
        echo "Failed to install v-analyzer. Please check the installation logs for more information."
        return 1
    fi    
fi

unminimize

echo "CRYSTAL INSTALLED."
