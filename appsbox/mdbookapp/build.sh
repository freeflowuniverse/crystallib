set -ex

cargo install mdbook
cargo install mdbook-admonish

cp ~/.cargo/bin/mdbook '${factory.bin_path}/mdbook'


echo "MDBook INSTALLED SUCCESFULLY"