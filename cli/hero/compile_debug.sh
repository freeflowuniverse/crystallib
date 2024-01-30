set -e
cd ~/code/github/freeflowuniverse/crystallib/cli/hero

export HEROPATH='/usr/local/bin/hero'    
if [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/hero
    # brew install libpq
    prf="$HOME/.profile"
    [ -f "$prf" ] && source "$prf"
fi

#!/bin/bash

v -cg -enable-globals -w hero.v

chmod +x hero


cp hero $HEROPATH
cp hero /tmp/hero
rm -f hero

echo "**COMPILE OK**"
