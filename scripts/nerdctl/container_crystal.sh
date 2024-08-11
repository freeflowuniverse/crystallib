#!/bin/bash
set -eux -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="crystal"
export BASENR=7

source lib/container_lib.sh

# heroc_delete $NAME
heroc_stop $NAME 7 
heroc_start $NAME 7 base

heroc_exec_script_ssh ${NAME} install_crystal.sh ${BASENR}022

#authorize_ssh_key "${BASENR}022"

#echo "passwd is admin for root", but should not be needed
#below is not using ssh
#heroc_shell ${NAME}

ssh -p ${BASENR}022 root@127.0.0.1 -A 'ls /'

nerdctl commit crystal crystal

ssh -p ${BASENR}022 root@127.0.0.1 -A



