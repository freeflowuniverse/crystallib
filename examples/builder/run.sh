#!/bin/bash
set -e

# Check if the SECRET environment variable is set
if [ -z "$SECRET" ]; then
    echo "Error: SECRET is not set."
    exit 1
fi

cd "$(dirname "$0")"

v -n -w -enable-globals toexec.v

 # Specify the local file to be copied and the remote destination
local_file='toexec'  # Replace with the path to your local file
remote_user='despiegk'
remote_host='192.168.99.1'
remote_path='/Users/despiegk/hero/bin/toexec'
remote_port='2222'


scp -P ${remote_port} "${local_file}" "${remote_user}@${remote_host}:${remote_path}"
ssh -t -p ${remote_port} "${remote_user}@${remote_host}" -A "/bin/zsh -c 'source ~/.zshrc && ${remote_path}' && echo 'DONE'"