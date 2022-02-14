module redisclient

// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:
import net
// import strconv
import time
import resp2
// import io

const default_read_timeout = net.infinite_timeout


pub struct Redis {
pub mut:
	connected bool
	socket    net.TcpConn
	addr    string
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
	instances    map[string]Redis
}

//needed to get singleton
fn init2() RedisFactory {
	mut f := redisclient.RedisFactory{
	}	
	return f
}


//singleton creation
const factory = init2()


// https://redis.io/topics/protocol
pub fn get(addr string) ?&Redis {
	mut f := redisclient.factory
	if ! (addr in f.instances){
		mut r := Redis{
			connected: true,
			addr: addr
		}
		r.socket_connect()?
		f.instances[addr] = r
	}
	mut r2:=f.instances[addr] 
	return &r2
}

//make sure to use new first, so that the connection has been initted
//then you can get it everywhere
pub fn get_local() &Redis {
	addr := "localhost:6379"
	return get(addr) or {
		&Redis{
			connected: false,
			addr: addr
		}
	}
}

//get a new one guaranteed, need for threads
pub fn get_local_new() ?&Redis {
	mut r := Redis{
		connected: true,
		addr: "localhost:6379"
	}
	r.socket_connect()?
	return &r
}



fn (mut r Redis) socket_connect()? {
	r.socket = net.dial_tcp(r.addr)?
	// mut socket := net.dial_tcp(addr) or { 
	// 	r.connected = false
	// }	
	r.socket.set_read_timeout(time.Duration(10 * time.second))
	r.socket.set_blocking(true)?
	r.socket.peer_addr()?
}

//THIS IS A WORKAROUND, not sure why we need this.
fn (mut r Redis) socket_check()? {
	r.socket.peer_addr() or {
		println(" - re-connect socket for redis")
		r.socket_connect()?
	}
}

// could not get it to work with buggered reader !!!, was blocking
pub fn (mut r Redis) read_line() ?string {
	// return r.socket.read_line().trim("\n\r") //had to trim to get it to work, readline returned too quickly
	mut buf := []byte{len: 1}
	mut out := []byte{}
	for {

		//WITH BUFFERED READER COULDNT GET THERE, WAS BLOCKING FOR EVER
		// mut buffer:= io.new_buffered_reader(reader:r.socket)
		// buffer.read(mut buf)?

		r.socket.read(mut buf) ?
	
		if buf == '\r'.bytes() {
			continue
		}
		if buf == '\n'.bytes() {
			res := out.bytestr()
			return res
		}
		out << buf
	}
	return error('timeout')
}

fn (mut r Redis) write_line(data_ []byte) ? {
	// is there no more efficient way, why do we do this?
	mut data := data_.clone()
	data << '\r'.bytes()
	data << '\n'.bytes()
	// println(' >> ' + data.bytestr())
	r.socket_check()?
	r.socket.write(data) ?
}

fn (mut r Redis) write(data []byte) ? {
	_ := r.socket.write(data) ?
}

// write resp2 value to the redis channel
pub fn (mut r Redis) write_rval(val resp2.RValue) ? {
	r.socket_check()?
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
