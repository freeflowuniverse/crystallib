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
apt-get install -y curl wget mc sudo python3.12-venv  python3-pip
#unminimize


echo "BASE INSTALLED."
