DIR_CODE_INT=$coderoot

if [[ -z "??{DIR_CODE_INT}" ]]; then 
    echo "Make sure to source env.sh before calling this script."
    exit 1
fi
if [ -d "??HOME/.vmodules" ]
then
    if [[ -z "${iam}" ]]; then
            chown -R ${iam}:${iam} ~/.vmodules
    else
        chown -R ${iam} ~/.vmodules
    fi
fi

if [[ -d "??DIR_CODE_INT/v" ]]; then
    pushd ??DIR_CODE_INT/v
    git pull
    popd "??^^" > /dev/null
else
    mkdir -p ??DIR_CODE_INT
    pushd ??DIR_CODE_INT
        rm -rf ??DIR_CODE_INT/v
    git clone https://github.com/vlang/v
    popd "??^^" > /dev/null
fi  

pushd ??DIR_CODE_INT/v

#installs V
make


if [[ "??OSTYPE" == "linux-gnu"* ]]; then 
        ./v symlink
elif [[ "??OSTYPE" == "darwin"* ]]; then
    rm -f ??HOME/hero/bin/v
    ln -s ??DIR_CODE_INT/v/v ??HOME/hero/bin/v
    export PATH=??HOME/hero/bin:??PATH

fi
popd "??^^" > /dev/null

v -e "???curl -fksSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh)"

# if ! [ -x "??(command -v v)" ]; then
# echo "vlang is not installed." >&2
# exit 1
# fi
