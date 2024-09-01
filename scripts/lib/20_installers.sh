
function freeflow_dev_env_install {

    set -ex

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

#check if reset should be done
reset

execute_with_marker "os_update" os_update

redis_start

sshknownkeysadd


