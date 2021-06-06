module redisclient

// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:
import net
// import strconv
import time
import despiegk.crystallib.resp2

pub struct Redis {
pub mut:
	connected bool
	socket    net.TcpConn
	// reader &io.BufferedReader
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
	mut socket := net.dial_tcp(addr) or { return Redis{
		connected: false
	} }

	socket.set_read_timeout(2 * time.second)

	return Redis{
		connected: true
		socket: socket
		// reader: io.new_buffered_reader(reader: io.make_reader(socket))
	}
}

// would be faster to do a buffered reader, but for now ok I guess
pub fn (mut r Redis) read_line() ?[]byte {
	mut buf := []byte{len: 1}
	mut out := []byte{}
	for {
		r.socket.read(mut buf) ?
		if buf == '\r'.bytes() {
			continue
		}
		if buf == '\n'.bytes() {
			// if out.bytestr() != '' {
			// 	println("readline result:'$out.bytestr()'")
			// }
			return out
		}
		out << buf
	}
	// mut res := r.socket.read_line()
	// // need to wait till something comes back, shouldn't this block? TODO:

	// for _ in 0 .. 10000 {
	// 	if res != '' {
	// 		res = res.trim('\n\r')
	// 		println("readline result:'$res'")
	// 		return res.bytes()
	// 	}
	// 	// ugly hack
	// 	time.sleep(time.microsecond)
	// 	res = r.socket.read_line()
	// 	println(" -- '$res'")
	// }

	return error('timeout')
}

fn (mut r Redis) write_line(data_ []byte) ? {
	// is there no more efficient way?
	mut data := data_.clone()
	data << '\r'.bytes()
	data << '\n'.bytes()
	println(' >> ' + data.bytestr())

	// mac os fix, this will fails if not connected
	r.socket.peer_addr() or {
		r.connected = false
		println('[-] could not fetch peer address')
		return
	}

	// this will silently close software
	// if socket is not connected (on macos)
	r.socket.write(data) ?
}

fn (mut r Redis) write(data []byte) ? {
	_ := r.socket.write(data) ?
}

// write resp2 value to the redis channel
pub fn (mut r Redis) write_rval(val resp2.RValue) ? {
	// macos: needed to avoid silent exit
	r.socket.peer_addr() or {
		println('[-] could not fetch peer address')
		return
	}

	_ := r.socket.write(val.encode()) ?
}

// write list of strings to redis challen
fn (mut r Redis) write_cmds(items []string) ? {
	a := resp2.r_list_bstring(items)
	r.write_rval(a) ?
}

fn (mut r Redis) read(size int) ?[]byte {
	mut buf := []byte{len: size}
	_ := r.socket.read(mut buf) ?
	return buf
}

pub fn (mut r Redis) disconnect() {
	r.socket.close() or {}
}
