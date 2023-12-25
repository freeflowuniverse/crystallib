function myexecdownload() {
    local script_name="$1"
    local download_url="$2"
    
    # Check if the script exists in the current directory
    if [ -f "./$script_name" ]; then
        echo "Script '$script_name' already exists in the current directory."
    else
        # Attempt to download the script
        echo "Script '$script_name' not found. Downloading from '$download_url'..."
        if curl -o "./$script_name" -s "$download_url"; then
            echo "Download successful. Script '$script_name' is now available in the current directory."
            chmod +x "./$script_name" # Make the script executable if needed
        else
            echo "Error: Download failed. Script '$script_name' could not be downloaded."
            exit 1
        fi
    fi
}

function myexec() {
    local script_name="$1"
    local download_url="$2"
    myexecdownload "$1" "$2"
    bash "${script_name}"
}
