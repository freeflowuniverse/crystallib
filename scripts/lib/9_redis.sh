

function redis_start {
    set +e
    if redis-cli ping | grep -q "PONG"; then
        echo "Redis is already running."
        return
    fi    
    set -e

    if [[ "${OSNAME}" == "darwin"* ]]; then
        brew services start redis
    # elif [[ "${OSNAME}" == "arch"* ]]; then
    #     redis-server --daemonize yes
    else
        if [[ "${OSNAME}" == "arch"* ]]; then
            RNAME='redis'
        else
            RNAME='redis-server'
        fi
        # Enable and start Redis service using the appropriate service manager
        if is_systemd_installed; then
            echo "Using systemd to manage Redis."
            systemctl enable ${RNAME}
            systemctl start ${RNAME}
        elif is_initd_installed; then
            echo "Using init.d to manage Redis."
            update-rc.d redis-server defaults
            service redis-server start
            #/etc/init.d/redis-server start                
        elif is_zinit_installed; then
            echo "Using zinit to manage Redis."
            echo 'exec: bash -c "/usr/bin/redis-server"' > /etc/zinit/redis.yaml
            zinit monitor redis
            zinit start redis
        else
            echo "Neither systemd nor init.d is installed. Cannot manage Redis service."
            exit 1
        fi

    fi

    redis_test

}


function redis_test {
    if redis-cli ping | grep -q "PONG"; then
        echo "Redis is running and responsive."
    else
        echo "Redis is not responding to PING."
        exit 1
    fi
}

