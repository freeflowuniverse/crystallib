set -ex


# git clone https://github.com/UlricE/pen
curl -L 'http://siag.nu/pub/pen/pen-${version}.tar.gz' -o pen.tar.gz
tar -xf pen.tar.gz
cd pen-@version

./configure
make

cp pen '${bin_path}/pen'

echo "PEN INSTALLED SUCCESFULLY"