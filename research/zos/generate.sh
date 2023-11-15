set -ex
cd $(dirname "$0")

rm -rf generated
mkdir -p generated
openrpc docgen -t "Zero OS OpenRPC API" -o generated methods.v