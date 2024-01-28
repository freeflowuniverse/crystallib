
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

    echo " - compile hero"
    ~/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh
    # source ~/.profile

    hero init

}

myplatform
os_update
github_keyscan

