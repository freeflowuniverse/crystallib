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
