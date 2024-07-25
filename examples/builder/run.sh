#!/bin/bash
set -ex

# Check if the SECRET environment variable is set
if [ -z "$SECRET" ]; then
    echo "Error: SECRET is not set."
    exit 1
fi

cd "$(dirname "$0")"


 v -n -w -enable-globals toexec.v