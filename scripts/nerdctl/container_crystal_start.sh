#!/bin/bash
set -eu -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="crystal"
export BASENR=7

source lib/container_lib.sh

heroc_start $NAME 7 

heroc_exec_script_ssh ${NAME} install_crystal.sh ${BASENR}022

ssh -p ${BASENR}022 root@127.0.0.1 -A 



