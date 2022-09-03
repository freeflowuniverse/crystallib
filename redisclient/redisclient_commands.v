module redisclient

import resp
import time

pub fn (mut r Redis) ping() ?string {
	return r.send_expect_strnil(['PING'])
}

pub fn (mut r Redis) set(key string, value string) ? {
	return r.send_expect_ok(['SET', key, value])
}

pub fn (mut r Redis) set_ex(key string, value string, ex string) ? {
	return r.send_expect_ok(['SET', key, value, 'EX', ex])
}

pub fn (mut r Redis) set_opts(key string, value string, opts SetOpts) bool {
	ex := if opts.ex == -4 && opts.px == -4 {
		''
	} else if opts.ex != -4 {
		' EX $opts.ex'
	} else {
		' PX $opts.px'
	}
	nx := if opts.nx == false && opts.xx == false {
		''
	} else if opts.nx == true {
		' NX'
	} else {
		' XX'
	}
	keep_ttl := if opts.keep_ttl == false { '' } else { ' KEEPTTL' }
	message := 'SET "$key" "$value"$ex$nx$keep_ttl\r\n'
	r.socket.write(message.bytes()) or { return false }
	time.sleep(1 * time.millisecond)
	res := r.socket.read_line()
	match res {
		'+OK\r\n' {
			return true
		}
		else {
			return false
		}
	}
}

pub fn (mut r Redis) get(key string) ?string {
	// mut key2 := key.trim("\"'")
	return r.send_expect_strnil(['GET', key])
}

pub fn (mut r Redis) exists(key string) ?bool {
	r2 := r.send_expect_int(['EXISTS', key])?
	return r2 == 1
}

pub fn (mut r Redis) del(key string) ?int {
	return r.send_expect_int(['DEL', key])
}

pub fn (mut r Redis) hset(key string, skey string, value string) ? {
	r.send_expect_int(['HSET', key, skey, value])?
}

pub fn (mut r Redis) hget(key string, skey string) ?string {
	// mut key2 := key.trim("\"'")
	return r.send_expect_strnil(['HGET', key, skey])
}

pub fn (mut r Redis) hgetall(key string) ?[]resp.RValue {
	// mut key2 := key.trim("\"'")
	return r.send_expect_list(['HGETALL', key])
}

pub fn (mut r Redis) hexists(key string, skey string) ?bool {
	return r.send_expect_bool(['HEXISTS', key, skey])
}

pub fn (mut r Redis) hdel(key string, skey string) ?int {
	return r.send_expect_int(['HDEL', key, skey])
}

pub fn (mut r Redis) incrby(key string, increment int) ?int {
	return r.send_expect_int(['INCRBY', key, increment.str()])
}

pub fn (mut r Redis) incr(key string) ?int {
	return r.incrby(key, 1)
}

pub fn (mut r Redis) decr(key string) ?int {
	return r.incrby(key, -1)
}

pub fn (mut r Redis) decrby(key string, decrement int) ?int {
	return r.incrby(key, -decrement)
}

pub fn (mut r Redis) incrbyfloat(key string, increment f64) ?f64 {
	res := r.send_expect_str(['INCRBYFLOAT', key, increment.str()])?
	count := res.f64()
	return count
}

pub fn (mut r Redis) append(key string, value string) ?int {
	return r.send_expect_int(['APPEND', key, value])
}

pub fn (mut r Redis) setrange(key string, offset int, value string) ?int {
	return r.send_expect_int(['SETRANGE', key, offset.str(), value.str()])
}

pub fn (mut r Redis) lpush(key string, element string) ?int {
	return r.send_expect_int(['LPUSH', key, element])
}

pub fn (mut r Redis) rpush(key string, element string) ?int {
	return r.send_expect_int(['RPUSH', key, element])
}

pub fn (mut r Redis) lrange(key string, start int, end int) ?[]resp.RValue {
	return r.send_expect_list(['LRANGE', key, start.str(), end.str()])
}

pub fn (mut r Redis) expire(key string, seconds int) ?int {
	return r.send_expect_int(['EXPIRE', key, seconds.str()])
}

pub fn (mut r Redis) pexpire(key string, millis int) ?int {
	return r.send_expect_int(['PEXPIRE', key, millis.str()])
}

pub fn (mut r Redis) expireat(key string, timestamp int) ?int {
	return r.send_expect_int(['EXPIREAT', key, timestamp.str()])
}

pub fn (mut r Redis) pexpireat(key string, millistimestamp i64) ?int {
	return r.send_expect_int(['PEXPIREAT', key, millistimestamp.str()])
}

pub fn (mut r Redis) persist(key string) ?int {
	return r.send_expect_int(['PERSIST', key])
}

pub fn (mut r Redis) getset(key string, value string) ?string {
	return r.send_expect_strnil(['GETSET', key, value])
}

pub fn (mut r Redis) getrange(key string, start int, end int) ?string {
	return r.send_expect_str(['GETRANGE', key, start.str(), end.str()])
}

pub fn (mut r Redis) keys(pattern string) ?[]string {
	response := r.send_expect_list(['KEYS', pattern])?
	mut result := []string{}
	for item in response {
		result << resp.get_redis_value(item)
	}
	return result
}

pub fn (mut r Redis) randomkey() ?string {
	return r.send_expect_strnil(['RANDOMKEY'])
}

pub fn (mut r Redis) strlen(key string) ?int {
	return r.send_expect_int(['STRLEN', key])
}

pub fn (mut r Redis) lpop(key string) ?string {
	return r.send_expect_strnil(['LPOP', key])
}

pub fn (mut r Redis) blpop(keys []string, timeout string) ?[]resp.RValue {
	mut cmds := ['BLPOP']
	cmds << keys
	cmds << timeout
	return r.send_expect_list(cmds)
}

pub fn (mut r Redis) rpop(key string) ?string {
	return r.send_expect_strnil(['RPOP', key])
}

pub fn (mut r Redis) llen(key string) ?int {
	return r.send_expect_int(['LLEN', key])
}

pub fn (mut r Redis) ttl(key string) ?int {
	return r.send_expect_int(['TTL', key])
}

pub fn (mut r Redis) pttl(key string) ?int {
	return r.send_expect_int(['PTTL', key])
}

pub fn (mut r Redis) rename(key string, newkey string) ? {
	return r.send_expect_ok(['RENAME', key, newkey])
}

pub fn (mut r Redis) renamenx(key string, newkey string) ?int {
	return r.send_expect_int(['RENAMENX', key, newkey])
}

pub fn (mut r Redis) setex(key string, second i64, value string) ? {
	return r.send_expect_ok(['SETEX', key, second.str(), value])
}

pub fn (mut r Redis) psetex(key string, millisecond i64, value string) ? {
	return r.send_expect_ok(['PSETEX', key, millisecond.str(), value])
}

pub fn (mut r Redis) setnx(key string, value string) ?int {
	return r.send_expect_int(['SETNX', key, value])
}

pub fn (mut r Redis) type_of(key string) ?string {
	return r.send_expect_strnil(['TYPE', key])
}

pub fn (mut r Redis) flushall() ? {
	return r.send_expect_ok(['FLUSHALL'])
}

pub fn (mut r Redis) flushdb() ? {
	return r.send_expect_ok(['FLUSHDB'])
}

// select is reserved
pub fn (mut r Redis) selectdb(database int) ? {
	return r.send_expect_ok(['SELECT', database.str()])
}

pub fn (mut r Redis) scan(cursor int) ?(string, []string) {
	res := r.send_expect_list(['SCAN', cursor.str()])?
	if res[0] !is resp.RBString {
		return error('Redis SCAN wrong response type (cursor)')
	}

	if res[1] !is resp.RArray {
		return error('Redis SCAN wrong response type (list content)')
	}

	mut values := []string{}

	for i in 0 .. resp.get_redis_array_len(res[1]) {
		values << resp.get_redis_value_by_index(res[1], i)
	}

	return resp.get_redis_value(res[0]), values
}
