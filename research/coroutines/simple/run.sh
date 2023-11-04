set -ex
cd $(dirname "$0")
v -cg -enable-globals -gc none -use-coroutines run simple.v
