module osal

const (
	redis_done_key = 'exec.done'
)

// Marks the execution of a command with a specific key as done by putting it in the hset exec.done in redis
pub fn (mut o Osal) done_set(key string, val string) ! {
	o.redis.hset(osal.redis_done_key, '${key}', val)!
}

// Tries to retrieve the value (string value) of a command that was executed by looking in the hset exec.done in redis, this function returns none in case it is not found in the hset
pub fn (mut o Osal) done_get(key string) ?string {
	val := o.redis.hget(osal.redis_done_key, '${key}') or { return none }
	return val
}

// Retrieves the value (string value) of a command that was executed by looking in the hset exec.done in redis, this function returns an empty string in case it is not found in the hset
pub fn (mut o Osal) done_get_str(key string) string {
	val := o.redis.hget(osal.redis_done_key, '${key}') or { return '' }
	return val
}

// Tries to retrieve the value (integer value) of a command that was executed by looking in the hset exec.done in redis, this function returns 0 in case it is not found in the hset
pub fn (mut o Osal) done_get_int(key string) int {
	val := o.redis.hget(osal.redis_done_key, '${key}') or { return 0 }
	return val.int()
}

// Returns true if the command has been executed (if it is found in the hset exec.done) and false in the other case
pub fn (mut o Osal) done_exists(key string) bool {
	_ := o.redis.hget(osal.redis_done_key, '${key}') or { return false }
	return true
}

// Logs all the commands that were executed on this system (looks in the hset exec.done to do so)
pub fn (mut o Osal) done_print() ! {
	mut output := 'DONE:\n'
	for key, val in o.redis.hgetall(osal.redis_done_key)! {
		output += '   . ${key} = ${val}'
	}
	o.logger.info('${output}')
}

// Remove all knowledge of executed commands
pub fn (mut o Osal) done_reset() ! {
	o.redis.del(osal.redis_done_key)!
}
