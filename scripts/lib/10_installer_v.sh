
function v_install {
    if [[ -z "${DIR_CODE_INT}" ]]; then 
        echo 'Make sure to source env.sh before calling this script.'
        exit 1
    fi
    if [ -d "$HOME/.vmodules" ]
    then
        if [[ -z "${USER}" ]]; then
            chown -R $USER:$USER ~/.vmodules
        else
            USER="$(whoami)"
            chown -R $USER ~/.vmodules
        fi
    fi

	if [[ ${OSNAME} == "ubuntu"* ]]; then
		package_install "libgc-dev gcc make libpq-dev"
	elif [[ ${OSNAME} == "darwin"* ]]; then
		brew install bdw-gc
	elif [[ ${OSNAME} == "alpine"* ]]; then
		package_install "make gcc libc-dev gcompat libstdc++"
	elif [[ ${OSNAME} == "arch" ]]; then
		package_install "make tcc gcc"
	else
		echo "ONLY SUPPORT OSX AND LINUX FOR NOW"
		exit 1
	fi

    if [[ -d "$DIR_CODE_INT/v" ]]; then
        pushd $DIR_CODE_INT/v
        git pull
        popd "$@" > /dev/null
    else
        mkdir -p $DIR_CODE_INT
        pushd $DIR_CODE_INT
        rm -rf $DIR_CODE_INT/v
        git clone  --depth 1  https://github.com/vlang/v
        popd "$@" > /dev/null
    fi

    pushd $DIR_CODE_INT/v
    make

    if [[ ${OSNAME} == "darwin"* ]]; then
        mkdir -p ${HOME}/hero/bin
        rm -f ${HOME}/hero/bin/v
        ln -s ${DIR_CODE_INT}/v/v ${HOME}/hero/bin/v
        popd "$@" > /dev/null
        export PATH="${HOME}/hero/bin:$PATH"
	else
        ${DIR_CODE_INT}/v/v symlink
    fi

    ##LETS NOT USE v-analyzer by default
    # # set -x
    # pushd /tmp
    # source ~/.profile
    # rm -f install.sh
    # curl -fksSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh > install.vsh
    # v run install.vsh  --no-interaction
    # popd "$@" > /dev/null
    # # set +x

    if ! [ -x "$(command -v v)" ]; then
    echo 'vlang is not installed.' >&2
    exit 1
    fi
}
