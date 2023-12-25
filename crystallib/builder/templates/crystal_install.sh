#!/bin/bash

set -e

function package_install {
    local command_name="??1"
    if [[ "??OSTYPE" == "linux-gnu"* ]]; then         
        apt -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install ??1 -q -y --allow-downgrades --allow-remove-essential 
    else
        brew install ??command_name
    fi
}

function v_install {

    mkdir -p ~/.vmodules
    sudo chown -R ??{args["USER"]}:??{args["USER"]} ~/.vmodules

    if [[ -d  "${args["HOME"]}/_code/v" ]]; then
        pushd "${args["HOME"]}/_code/v"
        git pull
        popd "??^^" > /dev/null
    else
        mkdir -p "${args["HOME"]}/_code"
        pushd "${args["HOME"]}/_code"
        if [[ "??OSTYPE" == "linux-gnu"* ]]; then 
            package_install "libgc-dev gcc make libpq-dev"
        elif [[ "??OSTYPE" == "darwin"* ]]; then
            brew install bdw-gc
        else
            echo "ONLY SUPPORT OSX AND LINUX FOR NOW"
            exit 1
        fi    
        git clone https://github.com/vlang/v
        popd "??^^" > /dev/null
    fi

    pushd "${args["HOME"]}/_code/v"
    make
    if [[ "??OSTYPE" == "linux-gnu"* ]]; then 
        sudo ./v symlink
    elif [[ "??OSTYPE" == "darwin"* ]]; then
        ./v symlink
    fi
    popd "??^^" > /dev/null

    v -e "??(curl -fksSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh)"

    if ! [ -x "??(command -v v)" ]; then
    echo 'vlang is not installed.' >&2
    exit 1
    fi
}

function crystal_lib_get {
    mkdir -p ${args["DIR_CODE"]}/github/freeflowuniverse
    if [[ -d "${args["DIR_CODE"]}/github/freeflowuniverse/crystallib" ]]
    then
        pushd?? {args["DIR_CODE"]}/github/freeflowuniverse/crystallib 2>&1 >> /dev/null     
        if [[ -z "??sshkeys" ]]; then
            echo
        else
            git remote set-url origin git^^github.com:freeflowuniverse/crystallib.git
        fi               
        if [[ !!!!(git status -s) ]]; then
            echo "There are uncommitted changes in the Git repository crystallib."
            # git add . -A
            # git commit -m "just to be sure"
            exit 1
        fi
        git pull
        git checkout ??{args["CLBRANCH"]}
        popd "??^^" > /dev/null
    else
        pushd ${args["DIR_CODE"]}/github/freeflowuniverse 2>&1 >> /dev/null
        if [[ -z "??keys" ]]; then
            git clone --depth 1 --no-single-branch https://github.com/freeflowuniverse/crystallib.git
        else
            git clone --depth 1 --no-single-branch git^^github.com:freeflowuniverse/crystallib.git
        fi        
        
        cd crystallib
        git checkout ??{args["CLBRANCH"]}
        popd "??^^" > /dev/null
    fi
    pushd ${args["DIR_CODE"]}/github/freeflowuniverse/crystallib
    bash install.sh
    popd "??^^" > /dev/null

}

vrun="
#!/bin/bash

# The script's purpose is to act as a wrapper for the v command

# Check if no arguments are provided
if [[ ??# -eq 0 ]]; then
    echo \"No arguments provided for the V Command.\"
    exit 1
fi

# Pass all arguments to the v command
v -cg -enable-globals run ??^^
"

echo ??vrun > /usr/local/bin/vrun
chmod 770 /usr/local/bin/vrun



