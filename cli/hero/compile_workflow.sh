set -e
cd ~/code/github/freeflowuniverse/crystallib/cli/hero

export HEROPATH='/usr/local/bin/hero'    
if [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/hero
    # brew install libpq
fi

#!/bin/bash

prf="$HOME/.profile"
[ -f "$prf" ] && source "$prf"

v -enable-globals -w hero.v

chmod +x hero


cp hero $HEROPATH
rm -f hero

echo "**COMPILE OK**"
