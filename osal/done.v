module osal

import redisclient
import log

const (
	redis_done_key = 'exec.done'
)

// Marks the execution of a command with a specific key as done by putting it in the hset exec.done in redis
pub fn done_set(key string, val string) ! {
	mut redis := redisclient.core_get()!
	redis.hset(osal.redis_done_key, '${key}', val)!
}

// Tries to retrieve the value (string value) of a command that was executed by looking in the hset exec.done in redis, this function returns none in case it is not found in the hset
pub fn done_get(key string) ?string {
	mut redis := redisclient.core_get() or { return none }
	val := redis.hget(osal.redis_done_key, '${key}') or { return none }
	return val
}

// Retrieves the value (string value) of a command that was executed by looking in the hset exec.done in redis, this function returns an empty string in case it is not found in the hset
pub fn done_get_str(key string) string {
	mut redis := redisclient.core_get() or { return '' }
	val := redis.hget(osal.redis_done_key, '${key}') or { return '' }
	return val
}

// Tries to retrieve the value (integer value) of a command that was executed by looking in the hset exec.done in redis, this function returns 0 in case it is not found in the hset
pub fn done_get_int(key string) int {
	mut redis := redisclient.core_get() or { return 0 }
	val := redis.hget(osal.redis_done_key, '${key}') or { return 0 }
	return val.int()
}

// Returns true if the command has been executed (if it is found in the hset exec.done) and false in the other case
pub fn done_exists(key string) bool {
	mut redis := redisclient.core_get() or { return false }
	val := redis.hget(osal.redis_done_key, '${key}') or { return false }
	if val == '' {
		return false
	}
	return true
}

// Logs all the commands that were executed on this system (looks in the hset exec.done to do so)
pub fn done_print() ! {
	mut output := 'DONE:\n'
	mut redis := redisclient.core_get()!
	for key, value in redis.hgetall(osal.redis_done_key)! {
		output += '\t${key} = ${value}\n'
	}
	mut logger := log.Logger(&log.Log{
		level: .info
	})
	logger.info('${output}')
}

// Remove all knowledge of executed commands
pub fn done_reset() ! {
	mut redis := redisclient.core_get()!
	redis.del(osal.redis_done_key)!
}
