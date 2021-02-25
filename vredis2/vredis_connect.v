module vredis2

import net
// import strconv
import time

struct Redis {
	pub mut:
		socket net.TcpConn
}

struct SetOpts {
	pub mut:
		ex       int=-4
		px       int=-4
		nx       bool
		xx       bool
		keep_ttl bool
}

enum KeyType {
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
	mut socket := net.dial_tcp(addr)?
	socket.set_read_timeout(2 * time.second)
	return Redis{
		socket: socket
	}
}

// fn (mut  r Redis) read() ?[]byte {
// 	mut data := []byte{len: 1024}
// 	r.reader.read(mut data)?
// 	return data
// }

pub fn (mut r Redis) socket_read_line() ?string {
	res := r.socket.read_line()
	if res == '' {
		return error("no data in socket")
	}
	// println("readline result:'$res'")
	return res
}

fn (mut r Redis) socket_write_line(data string) ? {
	r.socket.write('$data\r\n'.bytes())?
}

fn (mut r Redis) socket_write(data string) ? {
	return r.socket.write(data.bytes())
}

pub fn (mut r Redis) disconnect() {
	r.socket.close() or { }
}

//implement protocol of redis how to send he data
// https://redis.io/topics/protocol
fn (mut r Redis) encode_send_legacy(items []string)? {
	mut root := RedisValue{datatype: RedisValTypes.list}

	for item in items {
		obj := RedisValue{datatype: RedisValTypes.str, str: item}
		root.list << obj
	}

	return r.encode_send(root)
	/*
	mut out := "*${items.len}\r\n"
	for item in items{
		out+="\$${item.len}\r\n$item\r\n"
	}
	//for debug purposes
	println("redisdata:${out.replace("\n","\\n").replace("\r","\\r")}")
	r.socket_write(out)
	time.sleep_ms(1) // this is needed, not sure why
	*/
}

fn (mut r Redis) encode_value(value RedisValue) ?string {
	if value.datatype == RedisValTypes.str {
		return "\$${value.str.len}\r\n${value.str}\r\n"
	}

	if value.datatype == RedisValTypes.success {
		return "+${value.str}\r\n"
	}

	if value.datatype == RedisValTypes.err {
		return "-${value.str}\r\n"
	}

	if value.datatype == RedisValTypes.nil {
		return "$-1\r\n"
	}

	if value.datatype == RedisValTypes.num {
		return ":" + value.num.str() + "\r\n"
	}

	if value.datatype == RedisValTypes.list {
		mut buffer := "*${value.list.len}\r\n"
		for v in value.list {
			response := r.encode_value(v)?
			buffer = buffer + response
		}

		return buffer
	}

	// parsing error
	println("Could not prepare response")
	return "-Could not prepare response\r\n"
}

fn (mut r Redis) encode_send(value RedisValue)? {
	buffer := r.encode_value(value)?
	r.socket_write(buffer)?
	time.sleep_ms(10) // FIXME
}


enum ReceiveState {data error array}
enum RedisValTypes { str num nil list success err unknown }

struct RedisValue {
	mut:
		datatype RedisValTypes
		str string
		num int
		list []RedisValue
}

pub fn (mut r Redis) get_response()? RedisValue {
	mut result := RedisValue{}

	mut line := r.socket_read_line()?
	line = line[..line.len-2] // ignore the \r\n at the end

	if line.starts_with("-") {
		// error coming back from redis server
		// strip the - and set error
		return error(line[1..])
	}

	// parse integers
	if line.starts_with(":") {
		result.datatype = RedisValTypes.num
		result.num = line[1..].int()
		return result
	}

	if line.starts_with("+") {
		// default simple string
		// strip + and return value, works for OK aswell
		result.datatype = RedisValTypes.str
		result.str = line[1..]
		return result
	}

	if line.starts_with("$") {
		// bulk string value, extract length
		mut bulkstring_size := line[1..].int()

		if bulkstring_size == -1 {
			// represents null
			result.datatype = RedisValTypes.nil
			return result
		}

		result.datatype = RedisValTypes.str
		if bulkstring_size == 0 {
			// extract final \r\n and not reading
			// any payload
			r.socket_read_line()?
			result.str = ""
			return result
		}

		// read payload
		// println("waiting for $bulkstring_size bytes")
		mut buffer := []byte{len: bulkstring_size}

		len := r.socket.read(mut buffer) or { panic(err) }
		if len != bulkstring_size {
			eprintln("could not read enough data, fixme")
		}

		// extract final \r\n
		r.socket_read_line()?

		result.str = buffer.bytestr() // FIXME: won't support binary (afaik)
		return result
	}

	if line.starts_with("*") {
		result.datatype = RedisValTypes.list
		items := line[1..].int()

		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_response()?
			result.list << value
		}

		return result
	}

	return error("unsupported response type")
}

//return the int or string as string, if empty return then empty string
pub fn (mut r Redis) send(items []string)? RedisValue {
	r.encode_send_legacy(items)?
	return r.get_response()
}

pub fn (mut r Redis) send_ok(items []string) ? bool {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if res.datatype != RedisValTypes.str {
		return error("Wrong response, expected string")
	}

	return if res.str == "OK" { true } else { false }
}

pub fn (mut r Redis) send_int(items []string) ? int {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if res.datatype != RedisValTypes.num {
		return error("Wrong response, expected integer")
	}

	return res.num
}

pub fn (mut r Redis) send_str(items []string) ? string {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if res.datatype != RedisValTypes.str {
		return error("Wrong response, expected string")
	}

	return res.str
}

pub fn (mut r Redis) send_strnil(items []string) ? string {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if res.datatype == RedisValTypes.nil {
		return error("(nil)")
	}

	if res.datatype != RedisValTypes.str {
		return error("Wrong response, expected string/nil")
	}

	return res.str
}

pub fn (mut r Redis) send_list(items []string) ?[]RedisValue {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if res.datatype != RedisValTypes.list {
		return error("Wrong response, expected array")
	}

	return res.list
}

// fn parse_int(res string) ?int {
// 	sval := res[1..res.len - 2]
// 	return strconv.atoi(sval)
// }

// fn parse_float(res string) ?f64 {
// 	return strconv.atof64(res)
// }

