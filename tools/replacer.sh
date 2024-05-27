#!/bin/bash
set -ex
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${BASE_DIR}/myenv.sh

python ~/code/github/freeflowuniverse/crystallib/tools/replacer.py