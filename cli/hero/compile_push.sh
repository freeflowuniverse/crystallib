set -ex
cd ~/code/github/freeflowuniverse/crystallib/cli/hero
bash compile.sh
hero git_do -f freeflow_binary -cpp -m "new release hero" -script

