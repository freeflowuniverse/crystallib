#!/bin/bash
set -ex

# Check if the SECRET environment variable is set
if [ -z "$SECRET" ]; then
    echo "Error: SECRET is not set."
    exit 1
fi

# Specify the local file to be copied and the remote destination
local_file='/Users/despiegk1/hero/bin/hero'  # Replace with the path to your local file
remote_user='despiegk'
remote_host='192.168.99.1'
remote_path='/Users/despiegk/hero/bin/hero'
remote_port='2222'

/Users/despiegk1/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh

scp -P ${remote_port} "${local_file}" "${remote_user}@${remote_host}:${remote_path}"
#ssh -p ${remote_port} "${remote_user}@${remote_host}" -A "${remote_path}"

#ssh -t -p ${remote_port} "${remote_user}@${remote_host}" -A "/bin/zsh -c 'source ~/.zshrc && ${remote_path} -version'"

ssh -t -p ${remote_port} "${remote_user}@${remote_host}" -A "/bin/zsh -c 'source ~/.zshrc && ${remote_path} -version'"