set -ex
cd $(dirname "$0")
v -enable-globals openrpc.v
sudo mv openrpc /usr/local/bin/openrpc
echo "compiled openrpc"