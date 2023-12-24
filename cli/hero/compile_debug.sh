set -e
cd ~/code/github/freeflowuniverse/crystallib/cli/hero

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export HEROPATH='/usr/local/bin/hero'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/hero
    brew install libpq
fi


v -cg -enable-globals hero.v 
chmod +x hero


cp hero $HEROPATH
rm hero

echo "**COMPILE OK**"
