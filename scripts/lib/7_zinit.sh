

check_for_oneshot() {
    for arg in "$@"; do
        if [ "$arg" = "-oneshot" ]; then
            echo "Found '-oneshot' argument."
            return 0  # Indicates success (found)
        fi
    done
    return 1  # Indicates failure (not found)
}

function zinit_add {
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


function zinit_install {

    if [ "$(uname -m)" == "x86_64" ]; then
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
    min_file_size=$((5*1024*1024))

    curl -o "$destination_tmp_path" -L "$file_url"
    if [ $? -eq 0 ]; then
        file_size=$(stat -c%s "$destination_tmp_path")
        if [ "$file_size" -gt "$min_file_size" ]; then
            echo "Downloaded file is larger than 5MB."
            echo "Moving the file to $destination_path."
            rm -f destination_path
            sudo mv "$destination_tmp_path" "$destination_path"
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
