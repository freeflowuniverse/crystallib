
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

function docker_buildx_install {
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

