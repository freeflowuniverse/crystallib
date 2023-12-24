set -ex
cd $(dirname "$0")
# rm -f ~/_code/v/thirdparty/photon/photonwrapper.so
# v -o x -cg -enable-globals -gc none -use-coroutines simple.v
# cp ~/_code/v/thirdparty/photon/photonwrapper.so .
# ./x

v -o x -cg -enable-globals -gc none -use-coroutines run simple.v
