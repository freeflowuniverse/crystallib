set -ex
cd ~/code/github/freeflowuniverse/crystallib/baobab/hero/executor
v -enable-globals hero.v 
sudo cp hero /usr/local/bin/
rm hero