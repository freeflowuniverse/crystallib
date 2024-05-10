set -ex
cd $(dirname "$0")
#v -o x -cg -enable-globals -gc none -use-coroutines run channels.v
v -o x -cg -enable-globals -use-coroutines run channels4b.v
