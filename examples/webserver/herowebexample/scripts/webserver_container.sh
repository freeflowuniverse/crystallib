#!/bin/bash

# Run the Ubuntu container with host networking and a specific name
sudo docker run -d --net=host --name=hero-container ubuntu:latest tail -f /dev/null

# Create Directory .ssh in container
sudo docker exec -i hero-container bash -c "mkdir -p ~/.ssh"

# Copy SSH keys to container
sudo docker cp ~/.ssh/id_rsa hero-container:/root/.ssh/id_rsa
sudo docker cp ~/.ssh/id_rsa.pub hero-container:/root/.ssh/id_rsa.pub

# Execute all commands in a single docker exec call
sudo docker exec -i hero-container bash << EOF
set -e

# Install prerequisites
apt update && apt install -y git curl nano openssh-client libsqlite3-dev

# Set up SSH agent and add the key
eval \$(ssh-agent)
ssh-add ~/.ssh/id_rsa

# Clone the repository and set up the environment
mkdir -p ~/code/github/freeflowuniverse
cd ~/code/github/freeflowuniverse
git clone https://github.com/freeflowuniverse/crystallib
cd crystallib

# Download and run installation scripts
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/install_hero.sh > /tmp/hero_install.sh
bash /tmp/hero_install.sh
curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
bash /tmp/install.sh

# Run the example
~/code/github/freeflowuniverse/crystallib/examples/webserver/herowebexample/heroweb-example.vsh
EOF

# Attach to the container
docker attach hero-container