module resp2

import net
// import strconv
import time

struct Redis {
pub mut:
	socket net.TcpConn
}

struct SetOpts {
pub mut:
	ex       int = -4
	px       int = -4
	nx       bool
	xx       bool
	keep_ttl bool
}

// https://redis.io/topics/protocol
pub fn connect(addr string) ?Redis {
	mut socket := net.dial_tcp(addr) ?
	socket.set_read_timeout(2 * time.second)
	return Redis{
		socket: socket
	}
}

pub fn (mut r Redis) read_line() ?string {
	res := r.socket.read_line()
	if res == '' {
		return error('no data in socket')
	}
	// println("readline result:'$res'")
	return res
}

fn (mut r Redis) write_line(data string) ? {
	r.socket.write('$data\r\n'.bytes()) ?
}

fn (mut r Redis) write(data string) ?int {
	return r.socket.write(data.bytes())
}

pub fn (mut r Redis) disconnect() {
	r.socket.close() or { }
}

// pub fn (mut r Redis) get_response()? RValue {
// 	mut line := r.socket_read_line()?
// 	line = line[..line.len-2] // ignore the \r\n at the end

// 	if line.starts_with("-") {
// 		// error coming back from redis server
// 		// strip the - and set error
// 		return RError{value:line[1..]}
// 	}

// 	// parse integers
// 	if line.starts_with(":") {
// 		return RInt{value : line[1 ..].int()}
// 	}

// 	if line.starts_with("+") {
// 		// default simple string
// 		// strip + and return value, works for OK aswell
// 		return RString{value: line[1..]}
// 	}

// 	if line.starts_with("$") {
// 		// bulk string value, extract length
// 		mut bulkstring_size := line[1..].int()

// 		if bulkstring_size == -1 {
// 			// represents null
// 			return RNil{}
// 		}

// 		if bulkstring_size == 0 {
// 			// extract final \r\n and not reading
// 			// any payload
// 			r.socket_read_line()?
// 			return RString{value: ""}
// 		}

// 		// read payload
// 		// println("waiting for $bulkstring_size bytes")
// 		mut buffer := []byte{len: bulkstring_size}

// 		len := r.socket.read(mut buffer) or { panic(err) }
// 		if len != bulkstring_size {
// 			eprintln("could not read enough data, fixme")
// 		}

// 		// extract final \r\n
// 		r.socket_read_line()?
// 		return RString{value: buffer.bytestr()}  // FIXME: won't support binary (afaik)
// 	}

// 	if line.starts_with("*") {
// 		mut arr := RArray{
// 			values: []RValue{}
// 		}
// 		items := line[1..].int()

// 		// proceed each entries, they can be of any types
// 		for _ in 0 .. items {
// 			value := r.get_response()?
// 			arr.values << value
// 		}

// 		return arr
// 	}

// 	return error("unsupported response type")
// }
