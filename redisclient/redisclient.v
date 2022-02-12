module redisclient

// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:
import net
// import strconv
import time
import resp2
import io

const default_read_timeout = net.infinite_timeout


pub struct Redis {
pub mut:
	connected bool
	socket    net.TcpConn
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

[heap]
struct RedisFactory {
mut:
	instances    map[string]&Redis
}

//needed to get singleton
fn init2() RedisFactory {
	mut f := redisclient.RedisFactory{
	}	
	return f
}


//singleton creation
const factory = init2()

//make sure to use new first, so that the connection has been initted
//then you can get it everywhere
pub fn get_local() ?&Redis {
	name := 'local'
	mut f := redisclient.factory
	if ! (name in f.instances){
		rediscl := redisclient.connect("localhost:6379")?
		f.instances[name] = &rediscl
	}
	return f.instances[name]	
}

//get a new one guaranteed, need for threads
pub fn get_local_new() ?&Redis {
	mut r := redisclient.connect("localhost:6379")?
	return &r
}


// https://redis.io/topics/protocol
pub fn connect(addr string) ?Redis {
	mut socket := net.dial_tcp(addr) or { 
		return Redis{
			connected: false
		} 
	}
	mut r := Redis{
		connected: true,
		socket: socket
		// reader: io.new_buffered_reader(reader: io.make_reader(socket))
	}
	r.set_read_timeout(time.Duration(10 * time.second))?
	return r
}

pub fn (mut r Redis) set_read_timeout(timeout time.Duration)? {
	r.socket.set_read_timeout(timeout)
	r.socket.set_blocking(true)?
}

// would it be faster to do a buffered reader, but for now ok I guess
pub fn (mut r Redis) read_line() ?string {
	return r.socket.read_line().trim("\n\r")
	// mut buf := []byte{len: 1}
	// mut out := []byte{}
	// for {
	// 	// reader: io.new_buffered_reader(reader: io.make_reader(socket))
	// 	// r.socket.read(mut buf) ?
	// 	buffer.read(mut buf)?
	
	// 	if buf == '\r'.bytes() {
	// 		continue
	// 	}
	// 	if buf == '\n'.bytes() {
	// 		res := out.bytestr()
	// 		return res
	// 	}
	// 	out << buf
	// }
	// return error('timeout')
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
		println('[-] could not fetch peer address, socket not connected.')
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
