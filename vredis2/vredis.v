module vredis2


pub fn (mut r Redis) set(key string, value string) ?bool {
	return r.send_ok(['SET', key, value])
}

pub fn (mut r Redis) get(key string) ?string {
	// mut key2 := key.trim("\"'")
	return r.send_strnil(['GET', key])
}

// pub fn (mut r Redis) get(key string) string {
// 	message := 'GET "$key"\r\n'
// 	r.write(message) or {panic("cannot write message to redis")}
// 	res := r.socket_read_line() or {panic("cannot resd message from redis")}
// 	println(res)
// 	len := parse_int(res) or {panic("cannot parse int")}
// 	// if len == -1 {
// 	// 	return error('key not found')
// 	// }
// 	// return r.socket_read_line()
// 	return ""
// }

pub fn (mut r Redis) incrby(key string, increment int) ?int {
	return r.send_int(['INCRBY', key, increment.str()])
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
	res := r.send_str(['INCRBYFLOAT', key, increment.str()])?
	count := res.f64()
	return count
}

pub fn (mut r Redis) append(key string, value string) ?int {
	return r.send_int(['APPEND', key, value])
}

pub fn (mut r Redis) setrange(key string, offset int, value string) ?int {
	return r.send_int(['SETRANGE', key, offset.str(), value.str()])
}

pub fn (mut r Redis) lpush(key string, element string) ?int {
	return r.send_int(['LPUSH', key, element])
}

pub fn (mut r Redis) rpush(key string, element string) ?int {
	return r.send_int(['RPUSH', key, element])
}

pub fn (mut r Redis) expire(key string, seconds int) ?int {
	return r.send_int(['EXPIRE', key, seconds.str()])
}

pub fn (mut r Redis) pexpire(key string, millis int) ?int {
	return r.send_int(['PEXPIRE', key, millis.str()])
}

pub fn (mut r Redis) expireat(key string, timestamp int) ?int {
	return r.send_int(['EXPIREAT', key, timestamp.str()])
}

pub fn (mut r Redis) pexpireat(key string, millistimestamp i64) ?int {
	return r.send_int(['PEXPIREAT', key, millistimestamp.str()])
}

pub fn (mut r Redis) persist(key string) ?int {
	return r.send_int(['PERSIST', key])
}

pub fn (mut r Redis) getset(key string, value string) ?string {
	return r.send_strnil(['GETSET', key, value])
}

pub fn (mut r Redis) getrange(key string, start int, end int) ?string {
	return r.send_str(['GETRANGE', key, start.str(), end.str()])
}

pub fn (mut r Redis) randomkey() ?string {
	return r.send_strnil(['RANDOMKEY'])
}

pub fn (mut r Redis) strlen(key string) ?int {
	return r.send_int(['STRLEN', key])
}

pub fn (mut r Redis) lpop(key string) ?string {
	return r.send_strnil(['LPOP', key])
}

pub fn (mut r Redis) rpop(key string) ?string {
	return r.send_strnil(['RPOP', key])
}

pub fn (mut r Redis) llen(key string) ?int {
	return r.send_int(['LLEN', key])
}

pub fn (mut r Redis) ttl(key string) ?int {
	return r.send_int(['TTL', key])
}

pub fn (mut r Redis) pttl(key string) ?int {
	return r.send_int(['PTTL', key])
}

pub fn (mut r Redis) exists(key string) ?int {
	return r.send_int(['EXISTS', key])
}

pub fn (mut r Redis) del(key string) ?int {
	return r.send_int(['DEL', key])
}

pub fn (mut r Redis) rename(key string, newkey string) ?bool {
	return r.send_ok(['RENAME', key, newkey])
}

pub fn (mut r Redis) renamenx(key string, newkey string) ?int {
	return r.send_int(['RENAMENX', key, newkey])
}

pub fn (mut r Redis) flushall() ?bool {
	return r.send_ok(['FLUSHALL'])
}

pub fn (mut r Redis) flushdb() ?bool {
	return r.send_ok(['FLUSHDB'])
}

// select is reserved
pub fn (mut r Redis) selectdb(database int) ?bool {
	return r.send_ok(['SELECT', database.str()])
}

pub fn (mut r Redis) scan(cursor int) ? (string, []string) {
	res := r.send_list(['SCAN', cursor.str()])?
	if typeof(res[0]) != RString {
		return error("Redis SCAN wrong response type (cursor)")
	}

	if typeof(res[1]) != RArray {
		return error("Redis SCAN wrong response type (list content)")
	}

	mut values := []string{}

	for i in 0 .. res[1].values.len {
		values << res[1].values[i].value
	}

	return res[0].value, values
}
