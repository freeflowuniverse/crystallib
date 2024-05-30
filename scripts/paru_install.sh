#!/bin/bash

# Check if builduser exists, create if not
if ! id -u builduser > /dev/null 2>&1; then
    sudo useradd -m builduser
    echo "builduser:$(openssl rand -base64 32 | sha256sum | base64 | head -c 32)" | sudo chpasswd
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/builduser
fi

# Change to /tmp directory
cd /tmp

# Install base-devel and git without confirmation
sudo pacman -S --needed --noconfirm base-devel git

rm -rf paru
# Clone paru from AUR
git clone https://aur.archlinux.org/paru.git

# Change ownership of the cloned directory to the regular user
sudo chown -R builduser:builduser paru

# Switch to the regular user to build and install the package
sudo -u builduser bash <<EOF
cd /tmp/paru
rustup default stable
makepkg -si --noconfirm
EOF

# Go back to the original user
cd ..
