#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y build-essential curl wget

# Download and install Rust non-interactively
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y

# Add Cargo's bin directory to PATH for this session
source $HOME/.cargo/env

# Install stable toolchain
# rustup toolchain install stable -y
rustup toolchain install stable
rustup component add rustfmt

# Verify installation
if command -v rustc >/dev/null 2>&1; then
    echo "Rust installed successfully. Version: $(rustc --version)"
else
    echo "Rust installation failed."
    exit 1
fi

echo "RUST INSTALLED."
