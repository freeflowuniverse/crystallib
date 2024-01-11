function redis_install {

    local response=$(redis-cli PING)

    # Check if the response is PONG
    if [[ "${response}" == "PONG" ]]; then
        return 
    fi

     nix-env --install redis

    # if [[ "${OSTYPE}" == "linux-gnu"* ]]; then 
    #     # package_install "libssl-dev redis"
    #     package_install "redis"
    #     set +e
    #     /etc/init.d/redis-server stop
    #     update-rc.d redis-server disable
    #     set -e
    #     if pgrep redis >/dev/null; then
    #         # If running, kill Redis server
    #         echo "redis is running. Stopping..."
    #         pkill redis-server
    #         echo "redis server has been stopped."
    #     else
    #         echo "redis server is not running."
    #     fi
    # elif [[ "${OSTYPE}" == "darwin"* ]]; then
    #     if ! [ -x "$(command -v redis-server)" ]; then
    #         brew install redis
    #         brew services start redis
    #     fi        
    # fi
}


#configure the redis in zinit
function zinit_add_redis {
    redis_install
    local cmd="
#!/bin/bash
if pgrep redis >/dev/null; then
    echo redis is running. Stopping...
    pkill redis-server
fi
redis-server
"
    # --port 7777

    local zinitcmd="
test: redis-cli  PING
"
    #-p 7777
    zinitinstall "redis" "${cmd}" "${zinitcmd}"
    unset zinitcmd
}
