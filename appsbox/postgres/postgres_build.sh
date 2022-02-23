set -ex

wget https://ftp.postgresql.org/pub/source/v14.2/postgresql-14.2.tar.gz
gunzip postgresql-14.2.tar.gz
tar xf postgresql-14.2.tar

mkdir -p ${postgres_path}
./configure --prefix='${postgres_path}'

make
make install

echo "POSTGRES SERVER INSTALLED SUCCESFULLY"