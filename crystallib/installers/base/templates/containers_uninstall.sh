#!/bin/bash
set -u -o pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Stop all running Docker containers and remove Docker images, containers, and volumes
if command_exists docker; then
    echo "Removing all Docker containers, images, and volumes..."
    docker stop $(docker ps -a -q) 2>/dev/null
    docker rm $(docker ps -a -q) 2>/dev/null
    docker rmi $(docker images -q) 2>/dev/null
    docker volume rm $(docker volume ls -q) 2>/dev/null
    docker system prune -a -f --volumes 2>/dev/null
    osascript -e 'quit app "Docker"'
    sudo rm -rf /Applications/Docker.app
    rm -f ~/Library/Preferences/com.docker.docker.plist
    rm -rf ~/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState
    rm -rf ~/Library/Containers/com.docker.docker
    rm -rf ~/Library/Containers/com.docker.helper
    rm -rf ~/Library/Application\ Support/Docker\ Desktop
    rm -rf ~/.docker
else
    echo "Docker is not installed. Skipping Docker cleanup."
fi


# Remove binaries from ~/hero/bin
echo "Removing binaries from ~/hero/bin..."
rm -f ~/hero/bin/lima*
rm -f ~/hero/bin/docker*
rm -f ~/hero/bin/podman*
rm -f ~/hero/bin/kube*

# Remove Lima VMs
if command_exists limactl; then
    echo "Removing Lima VMs..."
    limactl stop $(limactl list --quiet) 2>/dev/null
    limactl delete --force $(limactl list --quiet) 2>/dev/null
    limactl list
    rm -rf ~/.lima
else
    echo "limactl is not installed. Skipping Lima VM removal."
fi

echo "Remove containers process completed."