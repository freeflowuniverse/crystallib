#!/bin/bash
set -eux -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="c1"

source container_lib.sh

heroc_delete $NAME
heroc_start $NAME

heroc_exec_script ${NAME} install_postgresql.sh

#authorize_ssh_key "5022"

ssh -p 5022 root@127.0.0.1 -A 
