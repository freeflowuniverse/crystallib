#!/bin/bash
set -ex
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${BASE_DIR}/myenv.sh

cd $BASE_DIR

python3 -m pip install -r "$BASE_DIR/requirements.txt" 

# pip freeze > requirements.txt

#to make sure we have the paths towards hero in our library
echo "$BASE_DIR/lib/hero" >> "$BASE_DIR/.venv/lib/python3.12/site-packages/hero.pth"

#for osx    
# pip3 install psycopg2-binary
# psycopg2

echo "OK"


python3 -m pip install -r "requirements.txt" 