
function os_update {
    echo ' - os update'
    if [[ "${OSNAME}" == "ubuntu" ]]; then
        rm -f /var/lib/apt/lists/lock
        rm -f /var/cache/apt/archives/lock
        rm -f /var/lib/dpkg/lock*		
        export TERM=xterm
        export DEBIAN_FRONTEND=noninteractive
        dpkg --configure -a
        apt update -y
        set +e
        apt-mark hold grub-efi-amd64-signed
        set -e
        apt update -y
        # apt upgrade  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        # apt autoremove  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        apt install apt-transport-https ca-certificates curl software-properties-common  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        package_install "mc redis-server curl tmux screen net-tools git htop ca-certificates lsb-release screen"
    elif [[ "${OSNAME}" == "darwin"* ]]; then
        # if command -v brew >/dev/null 2>&1; then
        #     echo 'homebrew installed'
        # else 
        #     export NONINTERACTIVE=1
        #     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"            
        #     # unset NONINTERACTIVE
        # fi
        nix-env --install redis mc curl 
    elif [[ "${OSNAME}" == "alpine"* ]]; then
        apk update screen git htop tmux
        apk add mc nushell curl rsync htop redis bash bash-completion screen git
        sed -i 's#/bin/ash#/bin/bash#g' /etc/passwd             
    elif [[ "${OSNAME}" == "arch"* ]]; then
        pacman -Syy --noconfirm
        pacman -Syu --noconfirm
        pacman -Su --noconfirm mc fish  git tmux curl htop
    fi
}

