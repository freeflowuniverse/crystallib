
function package_check_install {
    local command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        echo "command '$command_name' is already installed."
    else    
        package_install '$command_name'
    fi
}

function package_install {
    local command_name="$1"
    if [[ "$OSNAME" == "ubuntu" ]]; then         
        apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
    elif [[ "$OSNAME" == "darwin"* ]]; then            
        brew install $command_name
    elif [[ "$OSNAME" == "alpine"* ]]; then            
        sudo -s apk add $command_name
    elif [[ "$OSNAME" == "arch"* ]]; then            
        sudo -s pacman -S $command_name --noconfirm
    else
        echo "platform : $OSNAME not supported"
        exit 1
    fi
}
