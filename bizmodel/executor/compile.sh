set -ex
cd ~/code/github/freeflowuniverse/crystallib/bizmodel/executor
v -enable-globals bizmodel.v 
sudo cp bizmodel /usr/local/bin/
rm bizmodel