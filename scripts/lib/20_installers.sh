
function freeflow_dev_env_install {

    if ! [ -x "$(command -v v)" ]; then
        v_install
    fi
    if ! [ -x "$(command -v redis-cli)" ]; then
        redis_install
    fi

    crystal_lib_get

}


myplatform
os_update
github_keyscan


