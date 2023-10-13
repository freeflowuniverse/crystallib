set -ex
cd ~/code/github/freeflowuniverse/crystallib/baobab/hero/executor
bash compile.sh
hero git_do -f freeflow_binary -cpp -m "new release hero" -script

