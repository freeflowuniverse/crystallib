#!/bin/bash

brew install dropbear



USER=$(whoami)
PERMISSIONS=700
USER_DIR=$(eval echo ~$USER)

# Change the permissions of the user's home directory
chmod $PERMISSIONS "$USER_DIR"

echo "Permissions for $USER_DIR set to $PERMISSIONS"

#start dropbear in foreground
dropbear -F -R -s -p 0.0.0.0:2222 -E