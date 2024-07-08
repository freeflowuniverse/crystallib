#!/bin/bash
set -x
cd "$(dirname "$0")"
source load.sh

# for i in $(seq 1 1000)
# do
#     redis-cli EVALSHA $LOGHASH 0 "AAA" "CAT1" "Example log message"
#     redis-cli EVALSHA $LOGHASH 0 "AAA" "CAT2" "Example log message"
# done

redis-cli EVALSHA $LOGGER_DEL 0

for i in $(seq 1 200)
do
    redis-cli EVALSHA $LOGGER_ADD 0 "BBB" "CAT2" "Example log message"
done

