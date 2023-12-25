#!/usr/bin/env bash
# set +x

if [[ -e $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh ]]; then
    rm -f $HOME/.env.sh
    if [[ -h "$HOME/env.sh" ]] || [[ -L "$HOME/env.sh" ]]; then
        echo 
    else   
        rm -f $HOME/env.sh        
        ln -s $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh $HOME/env.sh
    fi
fi

if [[ -z "${CLBRANCH}" ]]; then 
    # echo " - DEFAULT BRANCH FOR CRYSTALLIB SET"
    export CLBRANCH="development"
fi

if [[ -z "${BUILDERBRANCH}" ]]; then 
    export BUILDERBRANCH="development"
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

export DIR_BOOTSTRAP="$DIR_CODE/github/freeflowuniverse/crystallib/scripts"

export DEBIAN_FRONTEND=noninteractive

mkdir -p $DIR_BASE
mkdir -p $DIR_CODE
mkdir -p $DIR_CODE_INT
mkdir -p $DIR_BUILD
mkdir -p $DIR_BIN
mkdir -p $DIR_SCRIPTS

if [ -z "$TERM" ]; then
    export TERM=xterm
fi



if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo "SSH agent is not running."
    export sshkeys=''
else 
    export sshkeys=$(ssh-add -l)
fi



#############################################






################## INSTALLERS ##################


#configure the redis in zinit
function zinit_configure_redis {
    redis_install
    cmd="
#!/bin/bash
if pgrep redis >/dev/null; then
    echo redis is running. Stopping...
    pkill redis-server
fi
set -e
redis-server
"
    # --port 7777

    zinitcmd="
test: redis-cli  PING
"
    #-p 7777
    zinitinstall "redis"
    unset zinitcmd
}

function crystal_install {
    os_update    
    if ! [ -x "$(command -v v)" ]; then
        v_install
    fi
    if ! [ -x "$(command -v redis-cli)" ]; then
        redis_install
    fi

    crystal_lib_get
}

function hero_install {

    crystal_install



}


function myreset {
    find $HOME/.vmodules/ -type f -name "done_*" -exec rm {} \;
    if [[ -f "$HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh" ]]; then
        echo "copy env.sh to root"
        ln -s $HOME/code/github/freeflowuniverse/crystallib/scripts/env.sh ~/env.sh
    fi    
}


function myupdate {
    myreset
    (os_update)
    if [ $? -ne 0 ]; then
        echo "Could not execute os_update."
        exit 1
    fi
    (crystal_lib_get)
    if [ $? -ne 0 ]; then
        echo "Could not get crystal lib."
        exit 1
    fi
    (crystal_install)
    if [ $? -ne 0 ]; then
        echo "Could not install crystal."
        exit 1
    fi  
}

function mycrystal {
    myreset
    (crystal_lib_get)
    if [ $? -ne 0 ]; then
        echo "Could not get crystal lib."
        exit 1
    fi
    (crystal_install)
    if [ $? -ne 0 ]; then
        echo "Could not install crystal."
        exit 1
    fi    
}

function cdcrystal {
    cd "$HOME/code/github/freeflowuniverse/crystallib"
}



function myinit {
    myinit0
}

# myplatform
# resetcheck
# myinit

