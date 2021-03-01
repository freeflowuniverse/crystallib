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



// https://redis.io/topics/protocol
pub fn connect(addr string) ?Redis {
	mut socket := net.dial_tcp(addr)?
	socket.set_read_timeout(2 * time.second)
	return Redis{
		socket: socket
	}
}



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
	mut root := RValue(RArray{
		values: []
	})
	for item in items {
		root.values << RValue(RString{
			value: item
		})
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


fn (mut r Redis) encode_send(value RValue)? {
	buffer := value.encode()
	r.socket_write(buffer)?
	time.sleep_ms(10) // FIXME
}


enum ReceiveState {data error array}



pub fn (mut r Redis) get_response()? RValue {
	mut result := RValue{}

	mut line := r.socket_read_line()?
	line = line[..line.len-2] // ignore the \r\n at the end

	if line.starts_with("-") {
		// error coming back from redis server
		// strip the - and set error
		return RError{value:line[1..]}
	}

	// parse integers
	if line.starts_with(":") {
		return RInt{value : line[1 ..].int()}
	}

	if line.starts_with("+") {
		// default simple string
		// strip + and return value, works for OK aswell
		return RString{value: line[1..]}
	}

	if line.starts_with("$") {
		// bulk string value, extract length
		mut bulkstring_size := line[1..].int()

		if bulkstring_size == -1 {
			// represents null
			return RNill{}
		}

		if bulkstring_size == 0 {
			// extract final \r\n and not reading
			// any payload
			r.socket_read_line()?
			return RString{value: ""}
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
		return RString{value: buffer.bytestr()}  // FIXME: won't support binary (afaik)
	}

	if line.starts_with("*") {
		arr = RArray{
			values: []RValue{}
		}
		items := line[1..].int()

		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_response()?
			arr.values << value
		}

		return arr
	}

	return error("unsupported response type")
}

//return the int or string as string, if empty return then empty string
pub fn (mut r Redis) send(items []string)? RValue {
	r.encode_send_legacy(items)?
	return r.get_response()
}

pub fn (mut r Redis) send_ok(items []string) ? bool {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if typeof(res) != RString {
		return error("Wrong response, expected string")
	}

	return if res.value == "OK" { true } else { false }
}

pub fn (mut r Redis) send_int(items []string) ? int {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if typeof(res) != RInt {
		return error("Wrong response, expected integer")
	}

	return res.value
}

pub fn (mut r Redis) send_str(items []string) ? string {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if typeof(res) != RString {
		return error("Wrong response, expected string")
	}

	return res.value
}

pub fn (mut r Redis) send_strnil(items []string) ? string {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if typeof(res) == RNill {
		return error("(nil)")
	}

	if typeof(res) != RString {
		return error("Wrong response, expected string/nil")
	}

	return res.value
}

pub fn (mut r Redis) send_list(items []string) ?[]RValue {
	r.encode_send_legacy(items)?
	res := r.get_response()?

	if typeof(res) != RArray {
		return error("Wrong response, expected array")
	}

	return res.values
}

// fn parse_int(res string) ?int {
// 	sval := res[1..res.len - 2]
// 	return strconv.atoi(sval)
// }

// fn parse_float(res string) ?f64 {
// 	return strconv.atof64(res)
// }

