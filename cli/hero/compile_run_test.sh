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

v -cg -enable-globals -w hero.v

chmod +x hero


cp hero $HEROPATH
rm -f hero

hero init -redis

# hero run -u https://git.ourworld.tf/threefold_coop/info_asimov/src/branch/main/script3 -e
hero mdbook -u https://git.ourworld.tf/threefold_coop/info_asimov/src/branch/main/script3 -e

echo "**OK**"
