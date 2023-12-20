set -ex

function crystal_lib_get {
    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/crystallib" ]]
    then
        pushd $DIR_CODE/github/freeflowuniverse/crystallib 2>&1 >> /dev/null     
        if [[ -z "$sshkeys" ]]; then
            echo
        else
            git remote set-url origin git@github.com:freeflowuniverse/crystallib.git
        fi               
        if [[ $(git status -s) ]]; then
            echo "There are uncommitted changes in the Git repository crystallib."
            # git add . -A
            # git commit -m "just to be sure"
            exit 1
        fi
        git pull
        git checkout $CLBRANCH
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
    pushd $DIR_CODE/github/freeflowuniverse/crystallib
    bash install.sh
    popd

}

source_dir="/Users/${USER}/code"
target_dir="${HOME}/code"
if [ ! -e "$target_dir" ]; then
    if [ ! -e "$source_dir" ]; then
        DIR_CODE="${source_dir}"
        crystal_lib_get    
    fi
    # Check if the source directory exists
    if [ -d "$source_dir" ]; then
            ln -s "$source_dir" "$target_dir"
            echo "Created a symbolic link from $source_dir to $target_dir."
        fi
    else
        echo "$source_dir does not exist."
        exit 1
    fi
fi