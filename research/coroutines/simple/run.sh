set -ex
cd $(dirname "$0")
rm -f ~/_code/v/thirdparty/photon/photonwrapper.so
v -cg -enable-globals -gc none -use-coroutines run simple.v
