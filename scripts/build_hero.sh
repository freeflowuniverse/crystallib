#!/usr/bin/env bash
set -e

rm -f ${HOME}/.env.sh

touch ~/.profile

# remove_include_shell() {
#     for file in "$@"; do
#         if [[ -f "$file" ]]; then
#             sed -i '' '/env\.sh/d' "$file"
#             sed -i '' '/hero\/bin/d' "$file"
#             echo 'export PATH="$HOME/hero/bin:$PATH"' >> "$file"
#         fi
#     done
# }

# remove_include_shell "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.config/fish/config.fish" "$HOME/.zshrc"

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi

if [ -z "$TERM" ]; then
    export TERM=xterm
fi
export OURHOME="$HOME/hero"
export DIR_BASE="$HOME"
export DIR_BUILD="/tmp"
export DIR_CODE="$DIR_BASE/code"
export DIR_CODEWIKI="$OURHOME/codewiki"
export DIR_CODE_INT="$HOME/_code"
export DIR_BIN="$OURHOME/bin"
export DIR_SCRIPTS="$OURHOME/bin"

export DEBIAN_FRONTEND=noninteractive

mkdir -p $DIR_BASE
mkdir -p $DIR_CODE
mkdir -p $DIR_CODE_INT
mkdir -p $DIR_BUILD
mkdir -p $DIR_BIN
mkdir -p $DIR_SCRIPTS

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

#keys used to see how to checkout code, don't remove
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo " - SSH agent is not running."
    export sshkeys=''
else 
    export sshkeys=$(ssh-add -l)
fi





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


function gitcheck {
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


function sshknownkeysadd {
    mkdir -p ~/.ssh
    if ! grep github.com ~/.ssh/known_hosts > /dev/null
    then
        ssh-keyscan github.com >> ~/.ssh/known_hosts
    fi
    if ! grep git.ourworld.tf ~/.ssh/known_hosts > /dev/null
    then
        ssh-keyscan git.ourworld.tf >> ~/.ssh/known_hosts
    fi    
    git config --global pull.rebase false

}

# function mycommit {
#     gitcheck
#     # Check if we are inside a Git repository
#     if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#         git_root=$(git rev-parse --show-toplevel)
#         echo "You are inside a Git repository $git_root."
#         pushd "$git_root"        
#     else
#         echo commit crystallib
#         pushd "$DIR_CODE/github/freeflowuniverse/crystallib"  2>&1 > /dev/null
#     fi
#     if [[ -z "$sshkeys" ]]; then
#         echo
#     else
#         git remote set-url origin git@github.com:freeflowuniverse/crystallib.git
#     fi          
#     if [[ $(git status -s) ]]; then
#         echo There are uncommitted changes.
#         git add . -A
#         echo "Please enter a commit message:"
#         read commit_message
#         git commit -m "$commit_message"
#         git pull
#         git push
#     else
#         echo "no changes"
#     fi
#     popd   2>&1 >/dev/null
# }






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
    if [[ "${OSNAME}" == "ubuntu" ]]; then
        apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
    elif [[ "${OSNAME}" == "darwin"* ]]; then
        brew install $command_name
    elif [[ "${OSNAME}" == "alpine"* ]]; then
        apk add $command_name
    elif [[ "${OSNAME}" == "arch"* ]]; then
        pacman --noconfirm -Su $command_name
    else
        echo "platform : ${OSNAME} not supported"
        exit 1
    fi
}
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

function reset {
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
function check_for_oneshot {
	for arg in "$@"; do
		if [ "$arg" = "-oneshot" ]; then
			echo "Found '-oneshot' argument."
			return 0 # Indicates success (found)
		fi
	done
	return 1 # Indicates failure (not found)
}

function zinit_add {
	local script_name="$1"
    local cmd="$2"
	local cmdtest="$3"
	rm -f "/etc/zinit/cmds/${script_name}.sh"
	rm -f "/etc/zinit/${script_name}.yaml"
	mkdir -p /etc/zinit/cmds
	mkdir -p /etc/zinit/cmdstest
	if [[ -n ${cmd} ]]; then
		echo "${cmd}" >"/etc/zinit/cmds/${script_name}.sh"
		chmod 770 "/etc/zinit/cmds/${script_name}.sh"
	fi
	if [[ -n ${cmdtest} ]]; then
		mkdir -p /etc/zinit/cmdstest
		echo "${cmdtest}" >"/etc/zinit/cmdstest/${script_name}.sh"
		chmod 770 "/etc/zinit/cmdstest/${script_name}.sh"
	fi
	echo "${zinitcmd}" >"/etc/zinit/${script_name}.yaml"
	if [[ -n ${cmd} ]]; then
		echo "exec: bash -c \"/etc/zinit/cmds/${script_name}.sh\"" >>"/etc/zinit/${script_name}.yaml"
	fi
	if [[ -n ${cmdtest} ]]; then
		echo "test: bash -c \"/etc/zinit/cmdstest/${script_name}.sh\"" >>"/etc/zinit/${script_name}.yaml"
	fi
	if check_for_oneshot "$@"; then
		echo "oneshot: true" >>"/etc/zinit/${script_name}.yaml"
	fi
}

function zinit_install {

	if [[ "$(uname -m)" == "x86_64" ]]; then
		echo "This system is running an intel/amd 64-bit processor."
	else
		echo "This system is not running an intel/amd  64-bit processor."
		exit 1
	fi

	rm -f /usr/local/bin/zinit
	curl https://github.com/freeflowuniverse/freeflow_binary/raw/main/x86_64/zinit /usr/local/bin/zinit

	file_url="https://github.com/freeflowuniverse/freeflow_binary/raw/main/x86_64/zinit"
	destination_dir="/usr/local/bin"
	destination_tmp_path="/tmp/zinit0"
	destination_path="$destination_dir/zinit"
	min_file_size=$((5 * 1024 * 1024))

	curl -o "$destination_tmp_path" -L "$file_url"
	if [ $? -eq 0 ]; then
		file_size=$(stat -c%s "$destination_tmp_path")
		if [ "$file_size" -gt "$min_file_size" ]; then
			echo "Downloaded file is larger than 5MB."
			echo "Moving the file to $destination_path."
			rm -f destination_path
			mv "$destination_tmp_path" "$destination_path"
			if [ $? -eq 0 ]; then
				echo "File moved successfully."
			else
				echo "Error: Unable to move the file."
				exit 1
			fi
		else
			echo "Downloaded file is not larger than 5MB."
			exit 1
		fi
	else
		echo "Error: Unable to download the file."
		exit 1
	fi

	chmod 770 $destination_path

	mkdir -p /etc/zinit/

}

function initdinstall {

	if [[ ${OSTYPE} == "linux-gnu"* ]]; then
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
		echo "$servicefile" >$spath
		systemctl daemon-reload
		systemctl enable $script_name
		systemctl start $script_name
	fi
}

function checkzinit {
	zinit list 2>&1 >/dev/null
}

#get it in initd or other way
#to check :     tmux attach-session -t zinit
function zinitinit {
	if ! [[ ${OSTYPE} == "linux-gnu"* ]]; then
		echo "only support linux"
		exit 1
	fi
	(checkzinit)
	if [ $? -ne 0 ]; then
		#### zinit kill
		tmux_session="zinit"
		if tmux has-session -t "$tmux_session" &>/dev/null; then
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
	if ! command -v tmux &>/dev/null; then
		echo "tmux is not installed. Please install it before running this script."
		exit 1
	fi
	# Check if the tmux session exists
	if tmux has-session -t "$tmux_session" &>/dev/null; then
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
        /etc/init.d/redis-server start
    elif [[ "${OSNAME}" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            echo 'homebrew installed'
        else 
            export NONINTERACTIVE=1
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"            
            unset NONINTERACTIVE
        fi
        set +e
        brew services start redis
        set -e
    elif [[ "${OSNAME}" == "alpine"* ]]; then
        apk update screen git htop tmux
        apk add mc curl rsync htop redis bash bash-completion screen git
        sed -i 's#/bin/ash#/bin/bash#g' /etc/passwd             
    elif [[ "${OSNAME}" == "arch"* ]]; then
        pacman -Syy --noconfirm
        pacman -Syu --noconfirm
        pacman -Su --noconfirm mc git tmux curl htop redis screen net-tools git htop ca-certificates lsb-release screen
        redis-server --daemonize yes
    fi
}


function v_install {
    if [[ -z "${DIR_CODE_INT}" ]]; then 
        echo 'Make sure to source env.sh before calling this script.'
        exit 1
    fi
    if [ -d "$HOME/.vmodules" ]
    then
        if [[ -z "${USER}" ]]; then
            chown -R $USER:$USER ~/.vmodules
        else
            USER="$(whoami)"
            chown -R $USER ~/.vmodules
        fi
    fi

	if [[ ${OSNAME} == "ubuntu"* ]]; then
		package_install "libgc-dev gcc make libpq-dev"
	elif [[ ${OSNAME} == "darwin"* ]]; then
		brew install bdw-gc
	elif [[ ${OSNAME} == "alpine"* ]]; then
		package_install "make gcc libc-dev gcompat libstdc++"
	elif [[ ${OSNAME} == "arch" ]]; then
		package_install "make tcc gcc"
	else
		echo "ONLY SUPPORT OSX AND LINUX FOR NOW"
		exit 1
	fi

    if [[ -d "$DIR_CODE_INT/v" ]]; then
        pushd $DIR_CODE_INT/v
        git pull
        popd "$@" > /dev/null
    else
        mkdir -p $DIR_CODE_INT
        pushd $DIR_CODE_INT
        rm -rf $DIR_CODE_INT/v
        git clone  --depth 1  https://github.com/vlang/v
        popd "$@" > /dev/null
    fi

    pushd $DIR_CODE_INT/v
    make

    if [[ ${OSNAME} == "darwin"* ]]; then
        mkdir -p ${HOME}/hero/bin
        rm -f ${HOME}/hero/bin/v
        ln -s ${DIR_CODE_INT}/v/v ${HOME}/hero/bin/v
        popd "$@" > /dev/null
        export PATH="${HOME}/hero/bin:$PATH"
	else
        ${DIR_CODE_INT}/v/v symlink
    fi

    ##LETS NOT USE v-analyzer by default
    # # set -x
    # pushd /tmp
    # source ~/.profile
    # rm -f install.sh
    # curl -fksSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh > install.vsh
    # v run install.vsh  --no-interaction
    # popd "$@" > /dev/null
    # # set +x

    if ! [ -x "$(command -v v)" ]; then
    echo 'vlang is not installed.' >&2
    exit 1
    fi
}


function crystal_lib_get {
    set +x
    rm -rf ~/.vmodules/freeflowuniverse/
    rm -rf ~/.vmodules/threefoldtech/
    mkdir -p ~/.vmodules/freeflowuniverse/
    mkdir -p ~/.vmodules/threefoldtech/   

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
            exit 1
        fi
        git pull
        set +e
        git checkout $CLBRANCH
        set -e
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        if [[ -z "$sshkeys" ]]; then
            git clone --depth 1 --no-single-branch https://github.com/freeflowuniverse/crystallib.git
        else
            git clone --depth 1 --no-single-branch git@github.com:freeflowuniverse/crystallib.git
        fi        
        
        cd crystallib
        set +e
        git checkout $CLBRANCH
        set -e
        popd 2>&1 >> /dev/null
    fi

    mkdir -p ~/.vmodules/freeflowuniverse
    rm -f ~/.vmodules/freeflowuniverse/crystallib
    ln -s "$DIR_CODE/github/freeflowuniverse/crystallib/crystallib" ~/.vmodules/freeflowuniverse/crystallib

    crystal_web_get
}


function crystal_web_get {
    
    mkdir -p ~/.vmodules/freeflowuniverse/
    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/webcomponents" ]]
    then
        pushd $DIR_CODE/github/freeflowuniverse/webcomponents 2>&1 >> /dev/null     
        if [[ -z "$sshkeys" ]]; then
            echo
        else
            git remote set-url origin git@github.com:freeflowuniverse/webcomponents.git
        fi               
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        if [[ -z "$sshkeys" ]]; then
            git clone --depth 1 --no-single-branch https://github.com/freeflowuniverse/webcomponents
        else
            git clone --depth 1 --no-single-branch git@github.com:freeflowuniverse/webcomponents.git
        fi        
        popd 2>&1 >> /dev/null || exit
    fi

    mkdir -p ~/.vmodules/freeflowuniverse
    rm -f ~/.vmodules/freeflowuniverse/webcomponents
    ln -s "$DIR_CODE/github/freeflowuniverse/webcomponents/webcomponents" ~/.vmodules/freeflowuniverse/webcomponents

}


function crystal_pull {
    crystal_lib_get
    pushd $DIR_CODE/github/freeflowuniverse/crystallib
    git pull
    git checkout $CLBRANCH
    popd 2>&1 >> /dev/null
    pushd $DIR_CODE/github/freeflowuniverse/webcomponents
    git pull
    popd 2>&1 >> /dev/null
}

function freeflow_dev_env_install {

    crystal_lib_get

    if ! [ -x "$(command -v v)" ]; then
        v_install
    fi
    if ! [ -x "$(command -v redis-cli)" ]; then
        echo "CANNOT FIND REDIS-SERVER"
        exit 1
    fi

    local response=$(redis-cli PING)

    # Check if the response is PONG
    if [[ "${response}" == "PONG" ]]; then
        echo "REDIS OK"
    else
        echo "REDIS CLI INSTALLED BUT REDIS SERVER NOT RUNNING" 
        exit 1
    fi

}


function hero_build {

    freeflow_dev_env_install

    echo " - compile hero"
    ~/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh
    source ~/.profile

    hero init -d

}


myplatform
os_update
sshknownkeysadd


hero_build


echo HERO, V, CRYSTAL ALL OK
echo WE ARE READY TO HERO...