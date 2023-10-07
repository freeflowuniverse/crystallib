set -ex
cd ~/code/github/freeflowuniverse/crystallib/baobab/hero/executor
# v -cg -enable-globals run hero.v $@
v -cg -enable-globals run hero.v git_get git@github.com:freeflowuniverse/freeflow_binary.git