#!/bin/bash

echo "Starting Seahorse installation..."

# Update and upgrade the system
apt update
apt upgrade -y
apt install -y curl
apt install -y pkg-config build-essential libudev-dev

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_latest_github_release() {
    local repo=$1
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local latest_version

    if command -v curl >/dev/null 2>&1; then
        latest_version=$(curl -sSf "$api_url" | grep -oP '"tag_name": "\K(.*)(?=")')
    elif command -v wget >/dev/null 2>&1; then
        latest_version=$(wget -qO- "$api_url" | grep -oP '"tag_name": "\K(.*)(?=")')
    else
        echo "Error: Neither curl nor wget is available." >&2
        return 1
    fi

    if [ -z "$latest_version" ]; then
        echo "Error: Could not fetch the latest version." >&2
        return 1
    fi

    echo "$latest_version"
}

# Install/Update Rust
install_or_update_rust() {
    local latest_version=$(get_latest_github_release "rust-lang/rust")
    echo "Rust latest version is $latest_version" 

    if ! command_exists rustc; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    else
        local current_version=$(rustc --version | awk '{print $2}')
        
        # Remove the 'rust-' prefix from the version string
        latest_version=${latest_version#rust-}
        
        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating Rust from version $current_version to $latest_version..."
            rustup update stable
            updated_version=$(rustc --version | awk '{print $2}')
            echo "Rust updated to version $updated_version"
        else
            echo "Rust is already at the latest version ($current_version)."
        fi
    fi
}

# Install rustfmt
install_rustfmc() {
    if ! rustup component list | grep -q "rustfmt"; then
        echo "Installing rustfmt..."
        rustup component add rustfmt
    else
        echo "rustfmt is installed. Updating Rust will keep it up to date."
    fi
}

# Install/Update Solana
install_or_update_solana() {
    local latest_version=$(get_latest_github_release "solana-labs/solana")
    
    # Remove the 'v' prefix from the version string if present
    latest_version=${latest_version#v}
    echo "Solana latest version is $latest_version" 

    if ! command_exists solana; then
        echo "Solana is not installed"
        echo "Installing Solana version $latest_version..."
        sh -c "$(curl -sSfL https://release.solana.com/v$latest_version/install)"
        # echo 'export PATH="$PATH:$HOME/.local/share/solana/install/active_release/bin"' >> ~/.bashrc
        echo "Solana $latest_version has been installed."
    else
        local current_version=$(solana --version | awk '{print $2}')
        
        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating Solana from version $current_version to $latest_version..."
            sh -c "$(curl -sSfL https://release.solana.com/v$latest_version/install)"
            # echo 'export PATH="$PATH:$HOME/.local/share/solana/install/active_release/bin"' >> ~/.bashrc
            updated_version=$(solana --version | awk '{print $2}')
            echo "Solana updated to version $updated_version"
        else
            echo "Solana is already at the latest version ($current_version)."
        fi
    fi
}

# Function to get the latest Node.js version
get_latest_node_version() {
    curl -sL https://nodejs.org/dist/index.json | awk -F'"' '/^{/{print $4}' | sed 's/^v//' | head -n 1
}

# Install or update Node.js and npm
install_or_update_node_js_npm() {
    local latest_version=$(get_latest_node_version)
    echo "Node.js latest version is $latest_version" 

    if ! command_exists node; then
        echo "Installing Node.js version $latest_version..."
        curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
        apt-get install -y nodejs
    else
        local current_version=$(node -v | cut -d 'v' -f 2)
        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating Node.js from version $current_version to $latest_version..."
            curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
            apt-get install -y nodejs
        else
            echo "Node.js is already at the latest version ($current_version)."
        fi
    fi
}

# Function to get the latest Yarn version
get_latest_yarn_version() {
    curl -sS https://api.github.com/repos/yarnpkg/yarn/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'
}

# Install or update Yarn
install_or_update_yarn() {
    local latest_version=$(get_latest_yarn_version)
    echo "Yarn latest version is $latest_version" 

    if ! command_exists yarn; then
        echo "Installing Yarn..."
        npm install -g yarn
    else
        local current_version=$(yarn --version)
        
        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating Yarn from $current_version to $latest_version..."
            npm install -g yarn@latest
        else
            echo "Yarn is already up to date (version $current_version)"
        fi
    fi
}

# Function to get the latest Anchor version
get_latest_anchor_version() {
    curl -sS https://api.github.com/repos/coral-xyz/anchor/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'
}

# Install or update Anchor
install_or_update_anchor() {
    local latest_version=$(get_latest_anchor_version)
    echo "Anchor latest version is $latest_version" 

    if ! command_exists anchor; then
        echo "Installing Anchor..."
        cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
        avm install latest
        avm use latest
        # echo 'export PATH="$PATH:$HOME/.avm/bin"' >> ~/.bashrc
    else
        local current_version=$(anchor --version | awk '{print $2}')
        
        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating Anchor from $current_version to $latest_version..."
            avm update
            avm install latest
            avm use latest
            # echo 'export PATH="$PATH:$HOME/.avm/bin"' >> ~/.bashrc
        else
            echo "Anchor is already up to date (version $current_version)"
        fi
    fi
}

# Function to get the latest Seahorse version
get_latest_seahorse_version() {
    cargo search seahorse-lang --limit 1 | awk '/^seahorse-lang/ {print $3}' | tr -d '"'
}

# Function to get the current Seahorse version
get_current_seahorse_version() {
    seahorse --version 2>&1 | awk '{print $2}'
}

# Install or update Seahorse
install_or_update_seahorse() {
    local latest_version=$(get_latest_seahorse_version)
    echo "Seahorse latest version is $latest_version" 

    if ! command_exists seahorse; then
        echo "Installing Seahorse..."
        cargo install seahorse-lang
    else
        local current_version=$(get_current_seahorse_version)
        
        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating Seahorse from $current_version to $latest_version..."
            cargo install seahorse-lang --force
        else
            echo "Seahorse is already up to date (version $current_version)"
        fi
    fi
}

# Run the installation or update processes
install_or_update_rust
install_rustfmc
install_or_update_solana
install_or_update_node_js_npm
install_or_update_yarn
install_or_update_anchor
install_or_update_seahorse

# source $HOME/.bashrc # for solana and anchor

check_install() {
    local command="$1"
    local success_message="$2"
    local failure_message="$3"

    # ANSI color codes
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color

    # Run the command and capture its output
    local output
    output=$(eval "$command" 2>&1)
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        if [ -n "$output" ]; then
            echo -e "${GREEN}${success_message}${NC} ${output}"
        else
            echo -e "${GREEN}${success_message}${NC}"
        fi
    else
        echo -e "${RED}${failure_message}${NC}"
    fi

    return $exit_code
}

# Verify installations
echo ""
echo "---------- Verify Installations ----------"
check_install "rustc --version" "[+] rustc is installed" "[-] rustc is not installed"
check_install "rustfmt --version" "[+] rustfmt is installed" "[-] rustfmt is not installed"
check_install "solana --version" "[+] solana is installed" "[-] solana is not installed"
check_install "node --version" "[+] node is installed" "[-] node is not installed"
check_install "npm --version" "[+] npm is installed" "[-] npm is not installed"
check_install "yarn --version" "[+] yarn is installed" "[-] yarn is not installed"
check_install "anchor --version" "[+] anchor is installed" "[-] anchor is not installed"
check_install "seahorse -V" "[+] seahorse is installed" "[-] seahorse is not installed"
echo "------------------------------------------"
echo ""
echo "Installation and update complete."
