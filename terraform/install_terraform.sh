set -ex

pushd /tmp
rm -f tform.zip
rm -f terraform

curl -L '@url' -o tform.zip

unzip tform.zip

mkdir -p $home/git3

rm -f $home/git3/terraform
mv terraform $home/git3/terraform


popd

echo "TERRAFORM INSTALLED SUCCESFULLY"