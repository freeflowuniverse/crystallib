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
apt-get install -y build-essential pkg-config libudev-dev


# Add Cargo's bin directory to PATH for this session
source $HOME/.cargo/env

sh -c "$(curl -sSfL https://release.solana.com/v1.18.17/install)"


# Verify installation
if command -v solana --version >/dev/null 2>&1; then
    echo "Solana installed successfully. Version: $(solana --version)"
else
    echo "Solana installation failed."
    exit 1
fi

export CARGO_TARGET_DIR='/tmp/cargo-installHgBChF'

#https://book.anchor-lang.com/getting_started/installation.html
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install latest
avm use latest



#cargo install seahorse-lang


echo "SOLANA + TOOLS INSTALLED."
