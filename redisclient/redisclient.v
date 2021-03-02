module redisclient

// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:
import net
import strconv
import time

pub struct Redis {
pub mut:
	socket net.TcpConn
}

pub struct SetOpts {
	ex       int = -4
	px       int = -4
	nx       bool
	xx       bool
	keep_ttl bool
}

pub enum KeyType {
	t_none
	t_string
	t_list
	t_set
	t_zset
	t_hash
	t_stream
	t_unknown
}

// https://redis.io/topics/protocol
pub fn connect(addr string) ?Redis {
	mut socket := net.dial_tcp(addr) ?
	socket.set_read_timeout(2 * time.second)
	return Redis{
		socket: socket
	}
}

pub fn (mut r Redis) socket_read_line() ?string {
	mut res := r.socket.read_line()
	// need to wait till something comes back, shouldn't this block? TODO:

	for _ in 0 .. 10000 {
		if res != '' {
			return res
		}
		// ugly hack
		time.sleep(time.microsecond)
		res = r.socket.read_line()
	}
	// println("readline result:'$res'")
	return error('timeout')
}

fn (mut r Redis) socket_write_line(data string) ? {
	r.socket.write('$data\r\n'.bytes()) ?
}

fn (mut r Redis) socket_write(data string) ? {
	_ := r.socket.write(data.bytes()) ?
}

pub fn (mut r Redis) disconnect() {
	r.socket.close() or { }
}

pub fn (mut r Redis) set(key string, value string) ? {
	message := 'SET "$key" "$value"\r\n'
	r.socket.write(message.bytes()) ?
	mut res := r.socket_read_line() ?
	res = res[0..3]
	match res {
		'+OK' {
			return
		}
		else {
			return error('could not set $key')
		}
	}
}

pub fn (mut r Redis) hset(key string, skey string, value string) ?int {
	message := 'HSET "$key" "$skey" "$value"\r\n'
	r.socket.write(message.bytes()) ?
	mut res := r.socket_read_line() ?
	len := parse_int(res)
	return len
}

pub fn (mut r Redis) set_opts(key string, value string, opts SetOpts) ? {
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
	r.socket.write(message.bytes()) ?
	mut res := r.socket_read_line() ?
	res = res[0..3]
	match res {
		'+OK' {
			return
		}
		else {
			return error('could not set_opts $key')
		}
	}
}

pub fn (mut r Redis) setex(key string, seconds int, value string) ? {
	return r.set_opts(key, value, SetOpts{
		ex: seconds
	})
}

pub fn (mut r Redis) psetex(key string, millis int, value string) ? {
	return r.set_opts(key, value, SetOpts{
		px: millis
	})
}

pub fn (mut r Redis) setnx(key string, value string) ? {
	return r.set_opts(key, value, SetOpts{
		nx: true
	})
}

pub fn (mut r Redis) incrby(key string, increment int) ?int {
	message := 'INCRBY "$key" $increment\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	rerr := parse_err(res)
	if rerr != '' {
		return error(rerr)
	}
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) incr(key string) ?int {
	res := r.incrby(key, 1) ?
	return res
}

pub fn (mut r Redis) decr(key string) ?int {
	res := r.incrby(key, -1) ?
	return res
}

pub fn (mut r Redis) decrby(key string, decrement int) ?int {
	res := r.incrby(key, -decrement) ?
	return res
}

pub fn (mut r Redis) incrbyfloat(key string, increment f64) ?f64 {
	message := 'INCRBYFLOAT "$key" $increment\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	rerr := parse_err(res)
	if rerr != '' {
		return error(rerr)
	}
	res2 := r.socket_read_line() ?
	count := parse_float(res2)
	return count
}

pub fn (mut r Redis) append(key string, value string) ?int {
	message := 'APPEND "$key" "$value"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) setrange(key string, offset int, value string) ?int {
	message := 'SETRANGE "$key" $offset "$value"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) lpush(key string, element string) ?int {
	message := 'LPUSH "$key" "$element"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) rpush(key string, element string) ?int {
	message := 'RPUSH "$key" "$element"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) expire(key string, seconds int) ?int {
	message := 'EXPIRE "$key" $seconds\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) pexpire(key string, millis int) ?int {
	message := 'PEXPIRE "$key" $millis\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) expireat(key string, timestamp int) ?int {
	message := 'EXPIREAT "$key" $timestamp\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) pexpireat(key string, millistimestamp i64) ?int {
	message := 'PEXPIREAT "$key" $millistimestamp\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) persist(key string) ?int {
	message := 'PERSIST "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) get(key string) ?string {
	message := 'GET "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == -1 {
		return error('key not found')
	}
	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) hget(key string, skey string) ?string {
	message := 'HGET "$key" "$skey"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == -1 {
		return error('key not found')
	}
	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) getset(key string, value string) ?string {
	message := 'GETSET "$key" $value\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == -1 {
		return ''
	}
	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) getrange(key string, start int, end int) ?string {
	message := 'GETRANGE "$key" $start $end\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == 0 {
		r.socket_read_line() ?
		return ''
	}
	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) randomkey() ?string {
	message := 'RANDOMKEY\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == -1 {
		return error('database is empty')
	}
	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) strlen(key string) ?int {
	message := 'STRLEN "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) lpop(key string) ?string {
	message := 'LPOP "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == -1 {
		return error('key not found')
	}

	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) rpop(key string) ?string {
	message := 'RPOP "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	len := parse_int(res)
	if len == -1 {
		return error('key not found')
	}
	res2 := r.socket_read_line() ?
	return res2[0..len]
}

pub fn (mut r Redis) llen(key string) ?int {
	message := 'LLEN "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	rerr := parse_err(res)
	if rerr != '' {
		return error(rerr)
	}
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) selectdb(database int) ? {
	message := 'SELECT "$database"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	rerr := parse_err(res)
	if rerr != '' {
		return error(rerr)
	}
}

pub fn (mut r Redis) ttl(key string) ?int {
	message := 'TTL "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) pttl(key string) ?int {
	message := 'PTTL "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) exists(key string) ?bool {
	message := 'EXISTS "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	if count == 1 {
		return true
	}
	return false
}

pub fn (mut r Redis) hexists(key string, skey string) ?bool {
	message := 'HEXISTS "$key" "$skey"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	if count == 1 {
		return true
	}
	return false
}

pub fn (mut r Redis) type_of(key string) ?KeyType {
	message := 'TYPE "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	return match res[1..res.len - 2] {
		'none' {
			KeyType.t_none
		}
		'string' {
			KeyType.t_string
		}
		'list' {
			KeyType.t_list
		}
		'set' {
			KeyType.t_set
		}
		'zset' {
			KeyType.t_zset
		}
		'hash' {
			KeyType.t_hash
		}
		'stream' {
			KeyType.t_stream
		}
		else {
			KeyType.t_unknown
		}
	}
}

pub fn (mut r Redis) del(key string) ?int {
	message := 'DEL "$key"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) hdel(key string, skey string) ?int {
	message := 'HDEL "$key" "$skey"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) rename(key string, newkey string) ? {
	message := 'RENAME "$key" "$newkey"\r\n'
	r.socket.write(message.bytes()) ?
	res2 := r.socket_read_line() ?
	res := res2[0..3]
	match res {
		'+OK' {
			return
		}
		else {
			return error('cannot rename $key')
		}
	}
}

pub fn (mut r Redis) renamenx(key string, newkey string) ?int {
	message := 'RENAMENX "$key" "$newkey"\r\n'
	r.socket.write(message.bytes()) ?
	res := r.socket_read_line() ?
	rerr := parse_err(res)
	if rerr != '' {
		return error(rerr)
	}
	count := parse_int(res)
	return count
}

pub fn (mut r Redis) flushall() ? {
	message := 'FLUSHALL\r\n'
	r.socket.write(message.bytes()) ?
	res2 := r.socket_read_line() ?
	res := res2[0..3]
	match res {
		'+OK' {
			return
		}
		else {
			return error('cannot flushall')
		}
	}
}

fn parse_int(res string) int {
	sval := res[1..res.len - 2]
	return strconv.atoi(sval) or { panic(err) }
}

fn parse_float(res string) f64 {
	return strconv.atof64(res)
}

fn parse_err(res string) string {
	if res.len >= 5 && res[0..4] == '-ERR' {
		return res[5..res.len - 2]
	} else if res.len >= 11 && res[0..10] == '-WRONGTYPE' {
		return res[11..res.len - 2]
	}
	return ''
}
