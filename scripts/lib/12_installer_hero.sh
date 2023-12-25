
function hero_install {

    echo ' - install hero'
    RELEASES="https://github.com/freeflowuniverse/freeflow_binary/raw/main"
    ASSET=""

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        ASSET="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ASSET="osx"
    fi
    if [[ "$(uname -m)" == "x86_64"* ]]; then
        ASSET="${ASSET}_x64"
    elif [[ "$(uname -m)" == "arm64"* ]]; then
        ASSET="${ASSET}_arm"
    fi

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        export HEROPATH='/usr/local/bin/hero'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        export HEROPATH=$HOME/hero/bin/hero
    fi

    ASSET="${ASSET}/hero"
    echo "${RELEASES}/${ASSET}"
    curl -sLO "${RELEASES}/${ASSET}"
    chmod +x hero
    mv hero $HEROPATH

    $HEROPATH init

    echo " - Successfully installed hero on $HEROPATH!"

}