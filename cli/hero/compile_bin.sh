set -ex
cd ~/code/github/freeflowuniverse/crystallib/cli/hero
v -enable-globals hero.v 
chmod +x hero
sudo cp hero /usr/local/bin/
rm hero

echo "**COMPILE OK**"