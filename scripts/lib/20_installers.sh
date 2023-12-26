
function freeflow_dev_env_install {

    crystal_lib_get

    if ! [ -x "$(command -v v)" ]; then
        v_install
    fi
    if ! [ -x "$(command -v redis-cli)" ]; then
        redis_install
    fi

    echo " - compile hero"
    ~/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh
    source ~/.profile

    hero init

}

myplatform
os_update
github_keyscan

