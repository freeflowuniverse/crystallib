
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
        apt upgrade  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        apt autoremove  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        apt install apt-transport-https ca-certificates curl software-properties-common  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
        package_install "rsync mc redis-server curl tmux screen net-tools git htop ca-certificates lsb-release binutils wget pkg-config"

    elif [[ "${OSNAME}" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            echo 'homebrew installed'
        else 
            export NONINTERACTIVE=1
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"            
            unset NONINTERACTIVE
        fi
        set +e
        brew install mc redis curl tmux screen htop wget
        set -e
    elif [[ "${OSNAME}" == "alpine"* ]]; then
        apk update screen git htop tmux
        apk add mc curl rsync htop redis bash bash-completion screen git
        sed -i 's#/bin/ash#/bin/bash#g' /etc/passwd             
    elif [[ "${OSNAME}" == "arch"* ]]; then
        pacman -Syy --noconfirm
        pacman -Syu --noconfirm
        pacman -Su --noconfirm arch-install-scripts gcc mc git tmux curl htop redis wget screen net-tools git sudo htop ca-certificates lsb-release screen

        # Check if builduser exists, create if not
        if ! id -u builduser > /dev/null 2>&1; then
            useradd -m builduser
            echo "builduser:$(openssl rand -base64 32 | sha256sum | base64 | head -c 32)" | chpasswd
            echo 'builduser ALL=(ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/builduser
        fi

        if [[ -n "${DEBUG}" ]]; then
            execute_with_marker "paru_install" paru_install
        fi
    fi
}

function paru_install {
    echo ' - paru install'
    pushd /tmp
    pacman -S --needed --noconfirm base-devel git
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    chown -R builduser:builduser paru

    # Switch to the regular user to build and install the package
    -u builduser bash <<EOF
    popd /tmp/paru
    rustup default stable
    makepkg -si --noconfirm
EOF
    

    # Go back to the original user
    popd
    popd

}