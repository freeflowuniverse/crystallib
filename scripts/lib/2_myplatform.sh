
function myplatform {
    if [[ "${OSTYPE}" == "darwin"* ]]; then
        export OSNAME='darwin'
    elif [ -e /etc/os-release ]; then
        # Read the ID field from the /etc/os-release file
        export OSNAME=$(grep '^ID=' /etc/os-release | cut -d= -f2)
        if [ "${os_id,,}" == "ubuntu" ]; then
            export OSNAME="ubuntu"          
        fi
        if [ "${OSNAME}" == "archarm" ]; then
            export OSNAME="arch"          
        fi        
        if [ "${OSNAME}" == "debian" ]; then
            export OSNAME="ubuntu"          
        fi            
    else
        echo "Unable to determine the operating system."
        exit 1        
    fi


    # if [ "$(uname -m)" == "x86_64" ]; then
    #     echo "This system is running a 64-bit processor."
    # else
    #     echo "This system is not running a 64-bit processor."
    #     exit 1
    # fi    

}

function is_root {
    if [ "$(whoami)" != "root" ]; then
        echo "This script must be run as root or with sudo."
        exit 1
    fi

}

# Function to check if systemd is installed
function is_systemd_installed {
    [ "$(ps -p 1 -o comm=)" = "systemd" ]
}

# Function to check if init.d is installed
function is_initd_installed {
    [ -d /etc/init.d ]
}

function is_zinit_installed {
    [ "$(ps -p 1 -o comm=)" = "zinit" ]
}




myplatformid() {
    local arch=$(uname -m)
    local os=$(uname -s)

    case "$os" in
        Linux*)
            case "$arch" in
                aarch64|arm64) echo "linux-arm64" ;;
                x86_64) echo "linux-i64" ;;
                *) echo "unknown" ;;
            esac
            ;;
        Darwin*)
            case "$arch" in
                arm64) echo "macos-arm64" ;;
                x86_64) echo "macos-i64" ;;
                *) echo "unknown" ;;
            esac
            ;;
        *)
            echo "unknown"
            ;;
    esac
}


export MYPLATFORMID=$(myplatformid)

if [ "$MYPLATFORMID" == "unknown" ]; then
    echo "Error: Unable to detect platform" >&2
    exit 1
fi
