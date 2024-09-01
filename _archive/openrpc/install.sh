set -ex

cd $(dirname "$0")

export HEROPATH='/usr/local/bin/openrpc'    
if [[ "$OSTYPE" == "darwin"* ]]; then
    export HEROPATH=$HOME/hero/bin/openrpc
    [ -f "$prf" ] && source "$prf"
    v -cg -enable-globals -w openrpc.v
else
    v -cg -enable-globals -w -cflags -static -cc gcc openrpc.v
fi


chmod +x openrpc


cp openrpc $HEROPATH
cp openrpc /tmp/openrpc
rm -f openrpc

echo "**COMPILE OK**"

