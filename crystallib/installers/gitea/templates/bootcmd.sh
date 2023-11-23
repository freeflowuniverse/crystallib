#!/bin/bash

# Replace 'username' with the target user's name
TARGET_USER="gitea"
# Replace 'your_command_here' with the command you want to execute
COMMAND="gitea web --config ${config_path.path} --verbose"

# Function to check if user exists
user_exists() {
    if id "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create user
create_user() {
    echo "Creating user $1..."
    # Add user creation command here. Modify it according to your needs.
    # The following command creates a new user with a home directory and no password
    sudo useradd -m "$1"
    # Check if user creation was successful
    if user_exists "$1"; then
        echo "User $1 created successfully."
    else
        echo "Failed to create user $1."
        exit 1
    fi
}

# Main logic
if user_exists "$TARGET_USER"; then
    echo "User $TARGET_USER exists."
else
    echo "User $TARGET_USER does not exist. Creating user..."
    create_user "$TARGET_USER"
fi

echo "Executing command as $TARGET_USER..."
sudo -u "$TARGET_USER" bash -c "$COMMAND"
