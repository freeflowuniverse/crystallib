#!/usr/bin/env bash
# set +x

if [[ -e $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh ]]; then
    rm -f $HOME/.env.sh
    if [[ -h "$HOME/env.sh" ]] || [[ -L "$HOME/env.sh" ]]; then
        echo 
    else   
        rm -f $HOME/env.sh        
        ln -s $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh $HOME/env.sh
    fi
fi


if [[ -z "${CLBRANCH}" ]]; then 
    # echo " - DEFAULT BRANCH FOR CRYSTALLIB SET"
    export CLBRANCH="development"
fi

if [[ -z "${BUILDERBRANCH}" ]]; then 
    export BUILDERBRANCH="development"
fi    

if [ -z "$TERM" ]; then
    export TERM=xterm
fi
export OURHOME="$HOME/play"
export DIR_BASE="$HOME"
export DIR_BUILD="/tmp"
export DIR_CODE="$DIR_BASE/code"
export DIR_CODEWIKI="$OURHOME/codewiki"
export DIR_CODE_INT="$OURHOME/_code"
export DIR_BIN="$OURHOME/bin"
export DIR_SCRIPTS="$OURHOME/bin"

export DIR_BOOTSTRAP="$DIR_CODE/github/freeflowuniverse/crystallib/scripts"

export DEBIAN_FRONTEND=noninteractive

mkdir -p $DIR_BASE
mkdir -p $DIR_CODE
mkdir -p $DIR_CODE_INT
mkdir -p $DIR_BUILD
mkdir -p $DIR_BIN
mkdir -p $DIR_SCRIPTS

if [ -z "$TERM" ]; then
    export TERM=xterm
fi



if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo "SSH agent is not running."
    export sshkeys=''
else 
    export sshkeys=$(ssh-add -l)
fi



#############################################

function bootstrap() {
    local script_name="$1"
    local download_url="$2"
    local scriptpath="$DIR_BOOTSTRAP/$script_name"
    
    # Check if the script exists in the current directory
    if [[ -f scriptpath ]]  ; then
        echo "Script '$scriptpath' exists in bootstrap."
        chmod +x $scriptpath
        bash $scriptpath
    else
        # Attempt to download the script
        echo "Script '$script_name' not found. Downloading from '$download_url'..."
        if curl -o "/tmp/$script_name" -s "$download_url"; then
            echo "Download successful. Script '$script_name' is now available in the current directory."
            chmod +x "/tmp/$script_name" # Make the script executable if needed
            bash "/tmp/$script_name"
        else
            echo "Error: Download failed. Script '$script_name' could not be downloaded."
            exit 1
        fi
    fi
}

gitcheck() {
    # Check if Git email is set
    if [ -z "$(git config user.email)" ]; then
        # If not set, prompt the user to enter it
        echo "Git email is not set."
        read -p "Enter your Git email: " git_email

        # Set the Git email
        git config --global user.email "$git_email"
        echo "Git email set to '$git_email'."
    else
        # Git email is already set
        echo "Git email is set to: $(git config user.email)"
    fi
}


function mycommit {
    gitcheck
    # Check if we are inside a Git repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git_root=$(git rev-parse --show-toplevel)
        echo "You are inside a Git repository $git_root."
        pushd "$git_root"        
    else
        echo commit crystallib
        pushd "$DIR_CODE/github/freeflowuniverse/crystallib"  2>&1 > /dev/null
    fi
    if [[ -z "$sshkeys" ]]; then
        echo
    else
        git remote set-url origin git@github.com:freeflowuniverse/crystallib.git
    fi          
    if [[ $(git status -s) ]]; then
        echo There are uncommitted changes.
        git add . -A
        echo "Please enter a commit message:"
        read commit_message
        git commit -m "$commit_message"
        git pull
        git push
    else
        echo "no changes"
    fi
    popd   2>&1 >/dev/null
}


pathmunge () {
    if ! echo "$PATH" | grep -Eq "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$1"
        else
            PATH="$1:$PATH"
        fi
    fi
}
pathmunge $DIR_BIN
pathmunge $DIR_SCRIPTS
pathmunge $DIR_BUILD


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
    bash "$script_name"
}


function github_keyscan {
    mkdir -p ~/.ssh
    if ! grep github.com ~/.ssh/known_hosts > /dev/null
    then
        ssh-keyscan github.com >> ~/.ssh/known_hosts
    fi
    git config --global pull.rebase false

}

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
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then         
        apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
    else
        brew install $command_name
    fi
}



function resetcheck {
    if [[ -z "${FULLRESET}" ]]; 
    then
        echo
    else
        rm -rf ~/.vmodules
        rm -rf ~/code  
    fi  

    if [[ -z "${RESET}" ]]; 
    then
        echo
    else
        rm -rf ~/.vmodules
    fi  

}


check_for_oneshot() {
    for arg in "$@"; do
        if [ "$arg" = "-oneshot" ]; then
            echo "Found '-oneshot' argument."
            return 0  # Indicates success (found)
        fi
    done
    return 1  # Indicates failure (not found)
}

function zinitinstall {
    local script_name="$1"
    local script_name_test="$2"    
    rm -f "/etc/zinit/cmds/$script_name.sh"
    rm -f "/etc/zinit/$script_name.yaml"
    mkdir -p /etc/zinit/cmds
    mkdir -p /etc/zinit/cmdstest
    if [[ -n "$cmd" ]]; then        
        echo "$cmd" > "/etc/zinit/cmds/$script_name.sh"
        chmod 770 "/etc/zinit/cmds/$script_name.sh"
    fi
    if [[ -n "$cmdtest" ]]; then
        mkdir -p /etc/zinit/cmdstest
        echo "$cmdtest" > "/etc/zinit/cmdstest/$script_name.sh"
        chmod 770 "/etc/zinit/cmdstest/$script_name.sh"
    fi    
    echo "$zinitcmd" > "/etc/zinit/$script_name.yaml"
    if [[ -n "$cmd" ]]; then
        echo "exec: bash -c \"/etc/zinit/cmds/$script_name.sh\"" >> "/etc/zinit/$script_name.yaml"
    fi    
    if [[ -n "$cmdtest" ]]; then
        echo "test: bash -c \"/etc/zinit/cmdstest/$script_name.sh\"" >> "/etc/zinit/$script_name.yaml"
    fi    
    if check_for_oneshot "$@"; then
        echo "oneshot: true" >> "/etc/zinit/$script_name.yaml"
    fi    
}

function initdinstall {
    set -x
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then     
        local script_name="$1"
        local cmd="$2"            
        servicefile="
[Unit]
Description=${script_name}
After=network.target 

[Service]
Type=simple
ExecStart=$cmd
WorkingDirectory=/tmp
Restart=always

[Install]
WantedBy=multi-user.target
"
        spath="/etc/systemd/system/${script_name}.service"
        rm -f $spath
        echo "$servicefile" > $spath
        systemctl daemon-reload 
        systemctl enable $script_name
        systemctl start $script_name
    fi
}

function checkzinit {
    zinit list 2>&1 > /dev/null
}

#get it in initd or other way
#to check :     tmux attach-session -t zinit
function zinitinit {
    if ! [[ "$OSTYPE" == "linux-gnu"* ]]; then    
        echo "only support linux"
        exit 1
    fi
    (checkzinit)
    if [ $? -ne 0 ]; then
        #### zinit kill
        tmux_session="zinit"
        if tmux has-session -t "$tmux_session" &> /dev/null; then
            # If the session exists, check if the window exists
            if tmux list-windows -t "$tmux_session" | grep -q "$tmux_window"; then
                # If the window exists, kill it
                tmux kill-window -t "$tmux_session:$tmux_window"
            fi
        fi        
        if pgrep zinit >/dev/null; then
            # If running, kill Redis server
            echo "zinit is running. Stopping..."
            pkill zinit
            echo "zinit server has been stopped."
        else
            echo "zinit server is not running."
        fi
        if [ -x "$(command -v systemctl)" ]; then
            echo "systemctl is installed."            
            initdinstall "zinit" "zinit init"
        else
            echo "initd is not installed."
            zinittmuxinit
        fi
        echo "zinit installed ok"
    fi

}


#!/bin/bash
function zinittmuxinit {
    # Specify the name of the tmux session and window
    tmux_session="zinit"
    tmux_window="zinit"
    command_to_execute="zinit init"
    # Check if tmux is installed
    if ! command -v tmux &> /dev/null; then
        echo "tmux is not installed. Please install it before running this script."
        exit 1
    fi
    # Check if the tmux session exists
    if tmux has-session -t "$tmux_session" &> /dev/null; then
        # If the session exists, check if the window exists
        if tmux list-windows -t "$tmux_session" | grep -q "$tmux_window"; then
            # If the window exists, kill it
            tmux kill-window -t "$tmux_session:$tmux_window"
        fi
    fi
    # Start a new tmux session with the desired window and execute the command
    tmux new-session -d -s "$tmux_session" -n "$tmux_window"
    tmux send-keys -t "$tmux_session:$tmux_window" "$command_to_execute" C-m
    echo "Started a new tmux session with window '$tmux_window' and executed '$command_to_execute'."
}

################## INSTALLERS ##################

function docker_install {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 

        set +ex
        apt-get remove docker docker-engine docker.io containerd runc -y 
        set -ex

        mkdir -p /etc/apt/keyrings

        rm -f /etc/apt/keyrings/docker.gpg

        curl -fksSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        chmod a+r /etc/apt/keyrings/docker.gpg
        
        apt-get update -y

        package_install docker-ce docker-ce-cli containerd.io docker-compose-plugin binfmt-support
        # mkdir -p /proc/sys/fs/binfmt_misc
        docker run hello-world
    fi
}

function buildx_install {
    export BUILDXDEST=$HOME/.docker/cli-plugins/docker-buildx
    mkdir -p $HOME/.docker/cli-plugins/
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        export BUILDXURL='https://github.com/docker/buildx/releases/download/v0.10.2/buildx-v0.10.2.linux-amd64' 
        rm -f $BUILDXDEST
        curl -Lk $BUILDXURL > $BUILDXDEST
        chmod +x $BUILDXDEST
        docker buildx install
        docker buildx create --use --name multi-arch-builder               

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        export BUILDXURL='https://github.com/docker/buildx/releases/download/v0.10.2/buildx-v0.10.2.darwin-arm64'
        #dont think its needed for osx
    fi

}


function v_install {
    set -e
    if [[ -z "${DIR_CODE_INT}" ]]; then 
        echo 'Make sure to source env.sh before calling this script.'
        exit 1
    fi
    if [ -d "$HOME/.vmodules" ]
    then
        if [[ -z "${USER}" ]]; then
            sudo chown -R $USER:$USER ~/.vmodules
        else
            USER="$(whoami)"
            sudo chown -R $USER ~/.vmodules
        fi
    fi

    if [[ -d "$DIR_CODE_INT/v" ]]; then
        pushd $DIR_CODE_INT/v
        git pull
        popd "$@" > /dev/null
    else
        mkdir -p $DIR_CODE_INT
        pushd $DIR_CODE_INT
        sudo rm -rf $DIR_CODE_INT/v
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
            package_install "libgc-dev gcc make libpq-dev"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install bdw-gc
        else
            echo "ONLY SUPPORT OSX AND LINUX FOR NOW"
            exit 1
        fi    
        git clone https://github.com/vlang/v
        popd "$@" > /dev/null
    fi

    pushd $DIR_CODE_INT/v
    make
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        sudo ./v symlink
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ./v symlink
    fi
    popd "$@" > /dev/null

    v -e "$(curl -fksSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh)"

    if ! [ -x "$(command -v v)" ]; then
    echo 'vlang is not installed.' >&2
    exit 1
    fi
}

function crystal_lib_get {
    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/crystallib" ]]
    then
        pushd $DIR_CODE/github/freeflowuniverse/crystallib 2>&1 >> /dev/null     
        if [[ -z "$sshkeys" ]]; then
            echo
        else
            git remote set-url origin git@github.com:freeflowuniverse/crystallib.git
        fi               
        if [[ $(git status -s) ]]; then
            echo "There are uncommitted changes in the Git repository crystallib."
            # git add . -A
            # git commit -m "just to be sure"
            exit 1
        fi
        git pull
        git checkout $CLBRANCH
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        if [[ -z "$keys" ]]; then
            git clone --depth 1 --no-single-branch https://github.com/freeflowuniverse/crystallib.git
        else
            git clone --depth 1 --no-single-branch git@github.com:freeflowuniverse/crystallib.git
        fi        
        
        cd crystallib
        git checkout $CLBRANCH
        popd 2>&1 >> /dev/null
    fi
    pushd $DIR_CODE/github/freeflowuniverse/crystallib
    bash install.sh
    popd

}

#configure the redis in zinit
function zinit_configure_redis {
    redis_install
    cmd="
#!/bin/bash
if pgrep redis >/dev/null; then
    echo redis is running. Stopping...
    pkill redis-server
fi
set -e
redis-server
"
    # --port 7777

    zinitcmd="
test: redis-cli  PING
"
    #-p 7777
    zinitinstall "redis"
    unset zinitcmd
}

function crystal_install {
    if ! [[ -f "$HOME/.vmodules/done_crystallib" ]]; then

        if ! [ -x "$(command -v v)" ]; then
        v_install
        fi

        os_update
        redis_install
        # if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        #     zinit_configure_redis
        # else
        #     redis_install
        # fi
        sudo rm -rf ~/.vmodules/
        mkdir -p ~/.vmodules/freeflowuniverse/
        mkdir -p ~/.vmodules/threefoldtech/   
        crystal_lib_get
        touch "$HOME/.vmodules/done_crystallib"
    fi
}



function os_update {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        apt update -y
        apt-mark hold grub-efi-amd64-signed
        apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" upgrade -q -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
        apt-mark hold grub-efi-amd64-signed
        apt update -y
        package_install "mc curl tmux net-tools git htop ca-certificates lsb-release"
        #gnupg
        apt upgrade -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo 
    fi
    touch "$HOME/.vmodules/done_os"
    echo "os update ok"
}


function redis_install {

    export response=$(redis-cli PING)

    # Check if the response is PONG
    if [ "$response" == "PONG" ]; then
        return 
    fi

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        # package_install "libssl-dev redis"
        package_install "redis"
        set +e
        /etc/init.d/redis-server stop
        update-rc.d redis-server disable
        set -e
        if pgrep redis >/dev/null; then
            # If running, kill Redis server
            echo "redis is running. Stopping..."
            pkill redis-server
            echo "redis server has been stopped."
        else
            echo "redis server is not running."
        fi
        set -e
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! [ -x "$(command -v redis-server)" ]; then
            brew install redis
            brew services start redis
        fi        
    fi
}

function myinit0 {

    if ! [[ -f "$HOME/.vmodules/done_init" ]]; then

        echo "do init"
        
        mkdir -p $HOME/.vmodules

        package_install curl

        github_keyscan

        if [[ "$OSTYPE" == "linux-gnu"* ]]; then        

            # Check if the /etc/os-release file exists
            if [ -e /etc/os-release ]; then
                # Read the ID field from the /etc/os-release file
                os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2)
                
                # Check if the ID is "ubuntu" (case-insensitive)
                if [ "${os_id,,}" == "ubuntu" ]; then
                    echo "This system is running Ubuntu."
                else
                    echo "This system is not running Ubuntu."
                    exit 1
                fi
            else
                echo "The /etc/os-release file does not exist. Unable to determine the operating system."
                exit 1
            fi

            # Check if the processor architecture is 64-bit
            if [ "$(uname -m)" == "x86_64" ]; then
                echo "This system is running a 64-bit processor."
            else
                echo "This system is not running a 64-bit processor."
                exit 1
            fi
        fi

        if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
            profile_file="$HOME/.profile"
            env_file="$HOME/env.sh"
            # Check if env.sh is already loaded in .profile
            if grep -q "source $env_file" "$profile_file"; then
                echo "env.sh is already loaded in .profile."
            else
                # Append the 'source' command to load env.sh in .profile
                echo "Adding 'source $env_file' to .profile..."
                echo "source $env_file" >> "$profile_file"
                echo "env.sh has been added to .profile."
            fi
        else
            profile_file="$HOME/.zprofile"
            env_file="$HOME/env.sh"
            # Check if env.sh is already loaded in .profile
            if grep -q "source $env_file" "$profile_file"; then
                echo "env.sh is already loaded in .zprofile."
            else
                # Append the 'source' command to load env.sh in .profile
                echo "Adding 'source $env_file' to .zprofile..."
                echo "source $env_file" >> "$profile_file"
                echo "env.sh has been added to .zprofile."
            fi        
        fi

        touch "$HOME/.vmodules/done_init"

    fi    

}

function myreset {
    find $HOME/.vmodules/ -type f -name "done_*" -exec rm {} \;
    if [[ -f "$HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh" ]]; then
        echo "copy env.sh to root"
        cp $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh ~/env.sh
    fi    
}


function myupdate {
    myreset
    (os_update)
    if [ $? -ne 0 ]; then
        echo "Could not execute os_update."
        exit 1
    fi
    (crystal_lib_get)
    if [ $? -ne 0 ]; then
        echo "Could not get crystal lib."
        exit 1
    fi
    (crystal_install)
    if [ $? -ne 0 ]; then
        echo "Could not install crystal."
        exit 1
    fi  
}

function mycrystal {
    myreset
    (crystal_lib_get)
    if [ $? -ne 0 ]; then
        echo "Could not get crystal lib."
        exit 1
    fi
    (crystal_install)
    if [ $? -ne 0 ]; then
        echo "Could not install crystal."
        exit 1
    fi    
}

function cdcrystal {
    cd "$HOME/code/github/freeflowuniverse/crystallib"
}



function myinit {
    myinit0
}

resetcheck
myinit

