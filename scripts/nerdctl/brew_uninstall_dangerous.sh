#!/bin/bash
set -eux -o pipefail

# Stop all running Docker containers and remove Docker images, containers, and volumes
echo "Removing all Docker containers, images, and volumes..."
docker stop $(docker ps -a -q) 2>/dev/null
docker rm $(docker ps -a -q) 2>/dev/null
docker rmi $(docker images -q) 2>/dev/null
docker volume rm $(docker volume ls -q) 2>/dev/null
docker system prune -a -f --volumes 2>/dev/null

# Uninstall Docker Desktop from macOS
echo "Uninstalling Docker Desktop..."
osascript -e 'quit app "Docker"'
sudo rm -rf /Applications/Docker.app
rm -f ~/Library/Preferences/com.docker.docker.plist
rm -rf ~/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState
rm -rf ~/Library/Containers/com.docker.docker
rm -rf ~/Library/Containers/com.docker.helper
rm -rf ~/Library/Application\ Support/Docker\ Desktop
rm -rf ~/.docker

# Remove nerdctl
echo "Removing nerdctl..."
nerdctl rm -a 2>/dev/null
nerdctl rmi -a 2>/dev/null

# Remove Lima VMs
echo "Removing Lima VMs..."
limactl stop $(limactl list --quiet) 2>/dev/null
limactl delete --force $(limactl list --quiet) 2>/dev/null

# Uninstall Homebrew and all installed packages
echo "Uninstalling Homebrew and all packages..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

# Verify removal and cleanup any remaining files
echo "Cleaning up remaining files and verifying removal..."
brew cleanup 2>/dev/null

sudo rm -rf /opt/homebrew

echo "Uninstallation process completed."
