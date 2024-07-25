#!/bin/bash
set -eux -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="base"
export BASENR=8

source lib/container_lib.sh

heroc_delete $NAME
heroc_start $NAME $BASENR 

heroc_exec_script_ssh ${NAME} install_base.sh ${BASENR}022

echo "passwd is admin for root"

#the ssh-agent should be active now
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${BASENR}022 root@127.0.0.1 -A 'ls /'
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${BASENR}022 root@127.0.0.1 -A

ssh -p ${BASENR}022 root@127.0.0.1 -A 'ls /'
ssh -p ${BASENR}022 root@127.0.0.1 -A

#heroc_shell ${NAME}


