set -ex
# Get the latest release URLs
urls=$(curl -s https://api.github.com/repos/freeflowuniverse/crystallib/releases/latest | grep browser_download_url | cut -d '"' -f 4)

echo $urls

# Identify current platform
os_name="$(uname -s)"
arch_name="$(uname -m)"

# Select the URL based on the platform
if [[ "$os_name" == "Linux" && "$arch_name" == "x86_64" ]]; then
    url=$(echo "$urls" | grep hero | grep "linux-i64")
elif [[ "$os_name" == "Darwin" && "$arch_name" == "arm64" ]]; then
    url=$(echo "$urls" | grep hero | grep "macos-arm64")
elif [[ "$os_name" == "Darwin" && "$arch_name" == "x86_64" ]]; then
    url=$(echo "$urls" | grep hero | grep "macos-i64")
else
    echo "Unsupported platform."
    exit 1
fi

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

    # Move and rename the file
    mv  /tmp/downloaded_file ~/hero/bin/hero

    # Make the file executable
    chmod +x ~/hero/bin/hero
    echo "Hero installed properly"
else
    echo "Downloaded file is less than 1 MB. Process aborted."
    exit 1
fi
