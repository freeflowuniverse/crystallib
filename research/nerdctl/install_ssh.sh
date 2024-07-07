#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

screen_kill() {
    local screen_name="$1"
    # Check if the screen session exists
    if screen -list | grep -q "$screen_name"; then
        echo "Found existing screen session: $screen_name"
        # Get the screen session PID
        local screen_pid=$(screen -ls | grep "$screen_name" | awk '{print $1}' | cut -d. -f1)
        # Kill the screen session and its child processes
        pkill -P $screen_pid
        kill $screen_pid
        echo "Killed existing screen session: $screen_name"
    fi
    screen -wipe
}

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive

# Update package list
apt-get update

# Install OpenSSH Server and screen non-interactively
apt-get install -y openssh-server screen htop mc curl git iproute2

# Enable root login in SSH config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set root password to 'admin'
echo "root:admin" | chpasswd

mkdir -p /run/sshd
chmod 0755 /run/sshd

echo 'export TERM=xterm' >> /root/.bashrc

export TERM=xterm
# Start SSH service in a screen session
screen_kill sshd
pkill sshd
screen -dmS sshd bash -c '/usr/sbin/sshd -D'

echo "OpenSSH installed, root login enabled, root password set to 'admin', and SSH daemon running in screen."
