#!/bin/bash
set -eux -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="crystal"

source container_lib.sh

heroc_delete $NAME
heroc_start $NAME 7 

heroc_exec_script_ssh ${NAME} install_crystal.sh 7022

#authorize_ssh_key "7022"

#echo "passwd is admin for root", but should not be needed

ssh -p 7022 root@127.0.0.1 -A 'ls /'
ssh -p 7022 root@127.0.0.1 -A 

#heroc_shell ${NAME}


