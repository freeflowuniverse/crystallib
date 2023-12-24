set -ex
cd $(dirname "$0")

rm -f ~/_code/v/thirdparty/photon/photonwrapper.so
v -o x -cg -enable-globals -gc none -use-coroutines channels.v
cp ~/_code/v/thirdparty/photon/photonwrapper.so .
./x

