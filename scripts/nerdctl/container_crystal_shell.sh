#!/bin/bash
set -eu -o pipefail
export MYPATH=$(dirname "$(realpath "$0")")
cd $MYPATH

export NAME="crystal"
export BASENR=7

ssh -p ${BASENR}022 root@127.0.0.1 -A 




