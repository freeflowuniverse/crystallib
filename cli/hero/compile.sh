set -ex
cd ~/code/github/freeflowuniverse/crystallib/cli/hero
v -enable-globals hero.v 
chmod +x hero
sudo cp hero /usr/local/bin/
mkdir -p ~/Downloads/
cp hero ~/Downloads/
rm hero

echo "**COMPILE OK**"
