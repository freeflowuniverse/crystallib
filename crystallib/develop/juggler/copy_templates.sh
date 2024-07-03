#!/bin/bash

# Set the default code root if CODEROOT is not set, using the home directory
CODEROOT="${CODEROOT:-$HOME/code}"

# Define the source folder path
SOURCE_PATH="$CODEROOT/github/freeflowuniverse/webcomponents/webcomponents/tailwind/juggler_templates"

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the destination folder path
DESTINATION_PATH="$SCRIPT_DIR/templates"

# Check if the source folder exists
if [ ! -d "$SOURCE_PATH" ]; then
  echo "Source folder does not exist: $SOURCE_PATH"
  exit 1
fi

# Copy the source folder to the destination path
cp -r "$SOURCE_PATH" "$DESTINATION_PATH"

# Check if the copy was successful
if [ $? -ne 0 ]; then
  echo "Failed to copy folder."
  exit 1
fi

echo "Folder copied successfully to $DESTINATION_PATH"
