


function hero_install {
    set -e
    
    redis_start

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

    if [[ "${OSNAME}" == "darwin"* ]]; then
        [ -f /usr/local/bin/hero ] && rm /usr/local/bin/hero
    fi

    if [ -z "$url" ]; then
        echo "Could not find url to download."
        echo $urls
        exit 1
    fi
    zprofile="${HOME}/.zprofile"
    hero_bin_path="${HOME}/hero/bin"
    temp_file="$(mktemp)"

    # Check if ~/.zprofile exists
    if [ -f "$zprofile" ]; then
        # Read each line and exclude any that modify the PATH with ~/hero/bin
        while IFS= read -r line; do
            if [[ ! "$line" =~ $hero_bin_path ]]; then
                echo "$line" >> "$temp_file"
            fi
        done < "$zprofile"
    else
        touch "$zprofile"
    fi
    # Add ~/hero/bin to the PATH statement
    echo "export PATH=\$PATH:$hero_bin_path" >> "$temp_file"
    # Replace the original .zprofile with the modified version
    mv "$temp_file" "$zprofile"
    # Ensure the temporary file is removed (in case of script interruption before mv)
    trap 'rm -f "$temp_file"' EXIT

    # Output the selected URL
    echo "Download URL for your platform: $url"

    # Download the file
    curl -o /tmp/downloaded_file -L "$url"

    # Check if file size is greater than 10 MB
    file_size=$(du -m  /tmp/downloaded_file | cut -f1)
    if [ "$file_size" -ge 10 ]; then
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
        export PATH=$PATH:$hero_bin_path
        hero -version
    else
        echo "Downloaded file is less than 10 MB. Process aborted."
        exit 1
    fi
}


function hero_upload {
    set -e    
    hero_path=$(which hero 2>/dev/null)
    if [ -z "$hero_path" ]; then
        echo "Error: 'hero' command not found in PATH" >&2
        exit 1
    fi
    set -x
    s3_configure
    rclone lsl b2:threefold/$MYPLATFORMID/
    rclone copy "$hero_path" b2:threefold/$MYPLATFORMID/
}
    