#!/bin/bash

# SSH and rsync configuration
SSH_HOST="verse.tf"
SSH_USER="root"
SOURCE_DIR="${HOME}/code/github/freeflowuniverse/crystallib/"
DEST_DIR="/root/code/github/freeflowuniverse/crystallib/"
FINAL_DIR="/root/code/github/freeflowuniverse/crystallib/examples/hero"

# Check if the source directory exists, if not stop
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory $SOURCE_DIR does not exist. Exiting."
  exit 1
fi

# Perform rsync over SSH, ignoring .git directory
#--exclude '.git' --exclude '.venv'
rsync -avz --delete -e ssh "$SOURCE_DIR/" "$SSH_USER@$SSH_HOST:$DEST_DIR/"

set -x

# SSH into the remote machine and change to the specified directory
ssh -At root@verse.tf "tmux attach-session -t main  || tmux new-session -s main -c ${FINAL_DIR}"
