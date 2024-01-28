#!/usr/bin/env bash
set -e

rm -f ${HOME}/.env.sh

touch ~/.profile

# remove_include_shell() {
#     for file in "$@"; do
#         if [[ -f "$file" ]]; then
#             sed -i '' '/env\.sh/d' "$file"
#             sed -i '' '/hero\/bin/d' "$file"
#             echo 'export PATH="$HOME/hero/bin:$PATH"' >> "$file"
#         fi
#     done
# }

# remove_include_shell "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.config/fish/config.fish" "$HOME/.zshrc"

if [[ -z "${CLBRANCH}" ]]; then 
    export CLBRANCH="development"
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

export DEBIAN_FRONTEND=noninteractive

mkdir -p $DIR_BASE
mkdir -p $DIR_CODE
mkdir -p $DIR_CODE_INT
mkdir -p $DIR_BUILD
mkdir -p $DIR_BIN
mkdir -p $DIR_SCRIPTS

pathmunge () {
    if ! echo "$PATH" | grep -Eq "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$1"
        else
            PATH="$1:$PATH"
        fi
    fi
}

pathmunge $DIR_BIN
pathmunge $DIR_SCRIPTS
pathmunge $DIR_BUILD

#keys used to see how to checkout code, don't remove
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo " - SSH agent is not running."
    export sshkeys=''
else 
    export sshkeys=$(ssh-add -l)
fi




