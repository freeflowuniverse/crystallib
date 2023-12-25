
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
        apt upgrade  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        apt autoremove  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        apt install apt-transport-https ca-certificates curl software-properties-common  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        package_install "mc curl tmux net-tools git htop ca-certificates lsb-release"
    elif [[ "${OSNAME}" == "darwin"* ]]; then
        echo 
    elif [[ "${OSNAME}" == "alpine"* ]]; then
        sudo -s apk update
        sudo -s apk add mc curl rsync htop redis bash bash-completion yq jq tmux git
        sed -i 's#/bin/ash#/bin/bash#g' /etc/passwd             
    elif [[ "${OSNAME}" == "arch"* ]]; then
        pacman -Syy --noconfirm
        pacman -Syu --noconfirm
        pacman -Su mc git tmux curl htop --noconfirm
    fi
}

