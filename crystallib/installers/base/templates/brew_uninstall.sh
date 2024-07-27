#!/bin/bash
set -ux -o pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


if command_exists brew; then
    # Uninstall Homebrew and all installed packages
    echo "Uninstalling Homebrew and all packages..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

    # Verify removal and cleanup any remaining files
    echo "Cleaning up remaining files and verifying removal..."
    brew cleanup 2>/dev/null

    sudo rm -rf /opt/homebrew

    echo "Uninstallation process completed for brew."
fi
