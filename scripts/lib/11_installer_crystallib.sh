
function crystal_lib_get {
    
    rm -rf ~/.vmodules/freeflowuniverse/
    rm -rf ~/.vmodules/threefoldtech/
    mkdir -p ~/.vmodules/freeflowuniverse/
    mkdir -p ~/.vmodules/threefoldtech/   

    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/crystallib" ]]
    then
        pushd $DIR_CODE/github/freeflowuniverse/crystallib 2>&1 >> /dev/null     
        if [[ -z "$sshkeys" ]]; then
            echo
        else
            git remote set-url origin git@github.com:freeflowuniverse/crystallib.git
        fi               
        # if [[ $(git status -s) ]]; then
        #     echo "There are uncommitted changes in the Git repository crystallib."
        #     # git add . -A
        #     # git commit -m "just to be sure"
        #     exit 1
        # fi
        # git pull
        # git checkout $CLBRANCH
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        if [[ -z "$keys" ]]; then
            git clone --depth 1 --no-single-branch https://github.com/freeflowuniverse/crystallib.git
        else
            git clone --depth 1 --no-single-branch git@github.com:freeflowuniverse/crystallib.git
        fi        
        
        cd crystallib
        git checkout $CLBRANCH
        popd 2>&1 >> /dev/null
    fi

    mkdir -p ~/.vmodules/freeflowuniverse
    rm -f ~/.vmodules/freeflowuniverse/crystallib
    ln -s "$DIR_CODE/github/freeflowuniverse/crystallib" ~/.vmodules/freeflowuniverse/crystallib

    crystal_web_get
}


function crystal_web_get {
    
    rm -rf ~/.vmodules/freeflowuniverse/
    mkdir -p ~/.vmodules/freeflowuniverse/

    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/webcomponents" ]]
    then
        pushd $DIR_CODE/github/freeflowuniverse/webcomponents 2>&1 >> /dev/null     
        if [[ -z "$sshkeys" ]]; then
            echo
        else
            git remote set-url origin git@github.com:freeflowuniverse/webcomponents.git
        fi               
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        if [[ -z "$keys" ]]; then
            git clone --depth 1 --no-single-branch https://github.com/freeflowuniverse/webcomponents
        else
            git clone --depth 1 --no-single-branch git@github.com:freeflowuniverse/webcomponents.git
        fi        
        popd 2>&1 >> /dev/null
    fi

    mkdir -p ~/.vmodules/freeflowuniverse
    rm -f ~/.vmodules/freeflowuniverse/webcomponents
    ln -s "$DIR_CODE/github/freeflowuniverse/webcomponents" ~/.vmodules/freeflowuniverse/webcomponents

}


function crystal_pull {
    crystal_lib_get
    pushd $DIR_CODE/github/freeflowuniverse/crystallib
    git pull
    git checkout $CLBRANCH
    popd 2>&1 >> /dev/null
    pushd $DIR_CODE/github/freeflowuniverse/webcomponents
    git pull
    popd 2>&1 >> /dev/null
}
