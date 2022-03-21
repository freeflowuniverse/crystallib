set -ex

git clone https://github.com/threefoldtech/tf-images $buildpath
cd $buildpath/tfgrid2/discourse_all_in_one

docker build -t $imagename .

echo "DISCOURSE BUILT SUCCESFULLY"
