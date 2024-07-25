#!/bin/bash
set -eux -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="rust"

source lib/container_lib.sh

# heroc_delete $NAME
# heroc_start $NAME 6 

#heroc_exec_script ${NAME} install_rust.sh
heroc_exec_script ${NAME} install_solana.sh


