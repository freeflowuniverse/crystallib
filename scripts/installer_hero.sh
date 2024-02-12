#!/usr/bin/env bash
set -e

# Identify current platform
os_name="$(uname -s)"
arch_name="$(uname -m)"

# Select the URL based on the platform
if [[ "$os_name" == "Linux" && "$arch_name" == "x86_64" ]]; then
    url="https://f003.backblazeb2.com/file/threefold/linux-i64/hero"
elif [[ "$os_name" == "Darwin" && "$arch_name" == "arm64" ]]; then
    url="https://f003.backblazeb2.com/file/threefold/macos-arm64/hero"
# elif [[ "$os_name" == "Darwin" && "$arch_name" == "x86_64" ]]; then
#     url="https://f003.backblazeb2.com/file/threefold/macos-i64/hero"
else
    echo "Unsupported platform."
    exit 1
fi

[ -f /usr/local/bin/hero ] && sudo rm /usr/local/bin/hero

if [ -z "$url" ]; then
    echo "Could not find url to download."
    echo $urls
    exit 1
fi

# Output the selected URL
echo "Download URL for your platform: $url"

# Download the file
curl -o /tmp/downloaded_file -L "$url"

# Check if file size is greater than 1 MB
file_size=$(du -m  /tmp/downloaded_file | cut -f1)
if [ "$file_size" -ge 1 ]; then
    # Create the target directory if it doesn't exist
    mkdir -p ~/hero/bin
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Move and rename the file
        mv  /tmp/downloaded_file ~/hero/bin/hero
        chmod +x ~/hero/bin/hero
    else
        mv  /tmp/downloaded_file /usr/local/bin/hero
        chmod +x /usr/local/bin/hero
    fi

    echo "Hero installed properly"
    hero -version
else
    echo "Downloaded file is less than 1 MB. Process aborted."
    exit 1
fi
