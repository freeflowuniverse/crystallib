#!/bin/bash
set -eux -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="crystal"

source container_lib.sh

heroc_delete $NAME
heroc_start $NAME 7 

heroc_exec_script ${NAME} install_crystal.sh

echo "passwd is admin for root"

# ssh -p 7022 root@127.0.0.1 -A

sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 7022 root@127.0.0.1 -A 'ls /'
sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 7022 root@127.0.0.1 -A

#heroc_shell ${NAME}


