set -ex

pushd /tmp
rm -f tform.zip
rm -f terraform

curl -L '$url' -o tform.zip

unzip tform.zip

mkdir -p $home/git3/bin

rm -f ${a.tf_cmd}
mv terraform ${a.tf_cmd}


popd

echo "TERRAFORM INSTALLED SUCCESFULLY"
