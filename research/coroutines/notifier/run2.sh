set -ex
cd $(dirname "$0")
v -o x -cg -enable-globals -gc none -use-coroutines run notifier.v
