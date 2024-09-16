#!/bin/bash

set -e
cd ~/code/github/freeflowuniverse/crystallib/cli/hero

if [ -f "$HOME/.zprofile" ]; then
  source "$HOME/.zprofile"
fi

export HEROPATH='/usr/local/bin/hero'    
if [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/hero
    # brew install libpq
    prf="$HOME/.profile"
    [ -f "$prf" ] && source "$prf"
    # v -cg -enable-globals -w -cflags -static -cc gcc hero.v
    v -w -cg -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals hero.v
else
    v -cg -enable-globals -w -n hero.v
    #v -cg -enable-globals -w -cflags -static -cc gcc hero.v
fi




chmod +x hero


cp hero $HEROPATH
cp hero /tmp/hero
rm -f hero

echo "**COMPILE OK**"
