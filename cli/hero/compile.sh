set -e
cd ~/code/github/freeflowuniverse/crystallib/cli/hero
v -enable-globals hero.v 
chmod +x hero

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export HEROPATH='/usr/local/bin/hero'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/hero
fi

cp hero $HEROPATH
rm hero

echo "**COMPILE OK**"
