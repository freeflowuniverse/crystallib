set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi


if [[ -z "${BUILDERBRANCH}" ]]; then 
    export BUILDERBRANCH="development"
fi    

export DEBIAN_FRONTEND=noninteractive

export OURHOME="$HOME"
export DIR_CODE="$OURHOME/code"
export OURHOME="$HOME/play"
mkdir -p $OURHOME

if [ -z "$TERM" ]; then
    export TERM=xterm
fi

function github_keyscan {
    mkdir -p ~/.ssh
    if ! grep github.com ~/.ssh/known_hosts > /dev/null
    then
        ssh-keyscan github.com >> ~/.ssh/known_hosts
    fi
}

if [[ -z "${FULLRESET}" ]]; 
then
    echo
else
    rm -rf ~/.vmodules
    rm -f ~/env.sh    
    rm -rf ~/code  
fi  

if [[ -z "${RESET}" ]]; 
then
    echo
else
    rm -rf ~/.vmodules
    rm -f ~/env.sh    
fi  


function os_package_install {
    apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install $1 -q -y --allow-downgrades --allow-remove-essential 
}

function os_update {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        apt update -y
        apt-mark hold grub-efi-amd64-signed
        apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" upgrade -q -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
        apt-mark hold grub-efi-amd64-signed
        os_package_install "mc curl tmux net-tools git htop ca-certificates gnupg lsb-release mc"
        apt upgrade -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo 
    fi
}

function redis_install {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        os_package_install "libssl-dev redis"
        /etc/init.d/redis-server start
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! [ -x "$(command -v redis-server)" ]; then
            brew install redis
        fi
        brew services start redis
    fi
}

function crystal_lib_get {
    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/crystallib" ]]
    then
        pushd $DIR_CODE/github/freeflowuniverse/crystallib 2>&1 >> /dev/null
        git pull
        git checkout $CLBRANCH
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        git clone --depth 1 --no-single-branch git@github.com:freeflowuniverse/crystallib.git
        cd crystallib
        git checkout $CLBRANCH
        popd 2>&1 >> /dev/null
    fi
    pushd $DIR_CODE/github/freeflowuniverse/crystallib
    bash install.sh
    popd

    # mkdir -p ~/.vmodules/freeflowuniverse
    # rm -f ~/.vmodules/freeflowuniverse/crystallib
    # ln -s ~/code/github/freeflowuniverse/crystallib ~/.vmodules/freeflowuniverse/crystallib 

}


function gridbuilder_get {

    mkdir -p $DIR_CODE/github/threefoldtech
    if [[ -d "$DIR_CODE/github/threefoldtech/vbuilders" ]]
    then
        pushd $DIR_CODE/github/threefoldtech/vbuilders 2>&1 >> /dev/null
        git pull
        git checkout $BUILDERBRANCH
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/threefoldtech 2>&1 >> /dev/null
        git clone --depth 1 --no-single-branch git@github.com:threefoldtech/vbuilders.git
        cd vbuilders        
        git checkout $BUILDERBRANCH
        popd 2>&1 >> /dev/null
    fi

    mkdir -p ~/.vmodules/threefoldtech
    rm -f ~/.vmodules/threefoldtech/builders
    ln -s ~/code/github/threefoldtech/vbuilders/builders ~/.vmodules/threefoldtech/builders


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
            os_package_install "libgc-dev gcc make libpq-dev"
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

        os_package_install docker-ce docker-ce-cli containerd.io docker-compose-plugin binfmt-support -y
        # mkdir -p /proc/sys/fs/binfmt_misc
        docker run hello-world
    fi
}


#important to first remove
rm -f $OURHOME/env.sh

if [[ -f "env.sh" ]]; then 
    #means we are working from an environment where env is already there e.g. when debug in publishing tools itself
    ln -sfv $PWD/env.sh $OURHOME/env.sh 
    if [[ -d "/workspace" ]]
    then
        ln -sfv $PWD/env.sh /workspace/env.sh 
    fi
else
    #https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/env.sh
    curl -k https://raw.githubusercontent.com/freeflowuniverse/crystallib/$CLBRANCH/scripts/env.sh > $OURHOME/env.sh
    if [[ -d "/workspace" ]]
    then
        cp $OURHOME/env.sh /workspace/env.sh 
    fi
    cp $OURHOME/env.sh $HOME/env.sh 
fi

bash -e $OURHOME/env.sh
source $OURHOME/env.sh

if [[ -z "${RESET}" ]]; then
  echo
else
  rm -f $HOME/.vmodules/done_crystallib
fi

if ! [ -x "$(command -v v)" ]; then
  v_install
fi



#CHECK IF DIR EXISTS, IF NOT CLONE
if ! [[ -f "$HOME/.vmodules/done_crystallib" ]]; then

    os_update
    redis_install

    sudo rm -rf ~/.vmodules/
    mkdir -p ~/.vmodules/freeflowuniverse/
    mkdir -p ~/.vmodules/threefoldtech/   

    github_keyscan

    crystal_lib_get
    # gridbuilder_get
    # docker_install
    # buildx_install

    touch "$HOME/.vmodules/done_crystallib"
fi



if [[ -z "${ANSIBLE}" ]]; then
    echo
else
    ansible_install
fi

# pushd $DIR_CT
# git pull
# popd "$@" > /dev/null

# if [[ -f "$HOME/.vmodules/done_crystallib" ]]; then
# pushd ~/.vmodules/despiegk/crystallib
# git pull
# popd "$@" > /dev/null
# fi

# # ct_reset
# ct_build
# build
# clear
# ct_help

# tmux ls


# pushd ~/.vmodules/freeflowuniverse/crystallib
# git status
# popd
# pushd  ~/.vmodules/threefoldtech/builders
# git status
# popd

echo "**** INSTALL WAS OK ****"

