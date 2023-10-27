set -e

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
fi




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

echo "**** V INSTALL WAS OK ****"

bash ~/code/github/freeflowuniverse/crystallib/cli/hero/compile.sh

echo "**** V INSTALL + HERO WAS OK ****"
