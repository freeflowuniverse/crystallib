set -ex
cd ~/code/github/freeflowuniverse/crystallib/baobab/hero/executor
v -enable-globals hero.v 
chmod +x hero
sudo cp hero /usr/local/bin/
cp hero ~/Downloads/
