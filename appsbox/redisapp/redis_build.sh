set -ex

rm -f redis-stable.tar.gz
curl http://download.redis.io/redis-stable.tar.gz > redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make

cp src/redis-server '${bin_path}/redis-server'
cp src/redis-cli '${bin_path}/redis-cli'

echo "REDIS SERVER INSTALLED SUCCESFULLY"