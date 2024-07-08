#redis-cli SCRIPT LOAD "$(cat logger.lua)"
export LOGGER_ADD=$(redis-cli SCRIPT LOAD "$(cat logger_add.lua)")
export LOGGER_DEL=$(redis-cli SCRIPT LOAD "$(cat logger_del.lua)")
export STATS_ADD=$(redis-cli SCRIPT LOAD "$(cat stats_add.lua)")
