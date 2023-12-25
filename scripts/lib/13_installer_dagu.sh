function dagu_install {

    platform=$(uname -m)
    url="https://github.com/dagu-dev/dagu/releases/download/v1.12.7/dagu_1.12.7_linux_amd64.tar.gz"
    if [ "$platform" == "aarch64" ]; then
        url="https://github.com/dagu-dev/dagu/releases/download/v1.12.7/dagu_1.12.7_linux_arm64.tar.gz"
    fi
    target_dir="/tmp/dagu"
    min_size_bytes=9000000
    mkdir -p "$target_dir"
    filename=$(basename "$url")
    curl -L -o "$target_dir/$filename" "$url"
    file_size=$(stat -c %s "$target_dir/$filename")
    if [ "$file_size" -ge "$min_size_bytes" ]; then
        tar -xzf "$target_dir/$filename" -C "$target_dir"
        echo "Extraction complete."
    else
        echo "$filename is too small (size: $file_size bytes). Removing the file."
        rm -f "$target_dir"
        exit 1
    fi
    mkdir -p ~/hero/bin/
    cp /tmp/dagu/dagu /usr/local/bin
}


function dagu_tmux {
    SESSION_NAME="dagu"
    if tmux has-session -t $SESSION_NAME 2>/dev/null; then
        tmux kill-session -t $SESSION_NAME
    fi
    tmux new-session -d -s $SESSION_NAME 'dagu server -s 0.0.0.0'

}