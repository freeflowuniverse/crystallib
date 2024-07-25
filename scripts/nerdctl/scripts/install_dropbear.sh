#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive

# Update package list
apt-get update

# Install Dropbear and other utilities non-interactively
apt-get install -y dropbear htop mc curl git iproute2

# Enable root login in Dropbear config
echo "DROPBEAR_EXTRA_ARGS='-w -g'" >> /etc/default/dropbear

# Set root password to 'admin'
echo "root:admin" | chpasswd

# Create Dropbear run directory and set permissions
mkdir -p /var/run/dropbear
chmod 0755 /var/run/dropbear

# Kill any existing Dropbear instances
pkill dropbear

echo "" > ~/.ssh/authorized_keys

# Ensure TERM environment variable is set
echo 'export TERM=xterm' >> /root/.bashrc
export TERM=xterm

# Start Dropbear on port 2299 in the background
/usr/sbin/dropbear -R -E -a -p 2299

echo "Dropbear installed, root login enabled, root password set to 'admin', and Dropbear running on port 2299 in the background."