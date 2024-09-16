#!/bin/bash
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
export BASE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
export BASE_DIR
export VENV_DIR="$BASE_DIR/.venv"

python3 -m venv "$VENV_DIR"
source $VENV_DIR/bin/activate

# Check if the directory exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Directory $VENV_DIR does not exist. Creating it and setting up a virtual environment."
    # The -p flag makes mkdir create any necessary parent directories as well
    mkdir -p "$VENV_DIR"
    # Create the virtual environment
    python3 -m venv "$VENV_DIR"
    python3 -m pip install --upgrade pip
fi

echo "We're good to go"