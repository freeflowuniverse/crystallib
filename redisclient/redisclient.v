module redisclient


// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:
import net
// import sync
// import strconv
import time
import freeflowuniverse.crystallib.resp
import os

__global (
	redis_connections shared []RedisInternal
	redis shared []Redis
)



const default_read_timeout = net.infinite_timeout

[heap]
struct RedisInternal {
mut:
	socket net.TcpConn
	addr   string
}


[heap]
pub struct Redis {
mut:
	current int				
pub mut:
	connection_nr   []int 	//is the position in the global

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
// examples:
//   localhost:6379
//   /tmp/redis-default.sock
pub fn new(addrs []string) !Redis {
	mut r := Redis{}
	lock redis_connections{
		// toadd:=[]string{}
		for addr in addrs{
			mut found:=false
			mut addr_nr:=0
			for conn in redis_connections{
				if conn.addr == addr{
					r.connection_nr << addr_nr //remember this connection nr
					found=true
					break
				}
				addr_nr+=1
			}
			if found{
				continue
			}else{
				//we need to make a new internal connection
				mut ri:=RedisInternal{addr:addr}
				redis_connections<<ri
				r.connection_nr << redis_connections.len-1
			}
		}
	}
	return r
}

pub fn get(addr string) !Redis {
	return new([addr])
}
fn (mut r RedisInternal) socket_connect() ! {
	addr := os.expand_tilde_to_home(r.addr)
	// print(' - REDIS CONNECT: ${addr}')
	r.socket = net.dial_tcp(addr)!
	r.socket.set_blocking(true)!
	r.socket.set_read_timeout(1 * time.second)
	// println("---OK")
}

fn (mut r RedisInternal) socket_check() ! {
	r.socket.peer_addr() or {
		// eprintln(' - re-connect socket for redis')
		r.socket_connect()!
	}
}

pub fn (mut r RedisInternal) read_line() !string {
	return r.socket.read_line().trim_right('\r\n')
}


// write *all the data* into the socket
// This function loops, till *everything is written*
// (some of the socket write ops could be partial)
fn (mut r RedisInternal) write(data []u8) ! {
	r.socket_check()!
	mut remaining := data.len
	for remaining > 0 {
		// zdbdata[data.len - remaining..].bytestr())
		written_bytes := r.socket.write(data[data.len - remaining..])!
		remaining -= written_bytes
	}
}


fn (mut r RedisInternal) read(size int) ![]u8 {
	r.socket_check() or {}
	mut buf := []u8{len: size}
	mut remaining := size
	for remaining > 0 {
		read_bytes := r.socket.read(mut buf[buf.len - remaining..])!
		remaining -= read_bytes
	}
	return buf
}

pub fn (mut r RedisInternal) disconnect() {
	r.socket.close() or {}
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

//TODO: need to implement a way how to use multiple connections at once

const cr_lf_bytes = [u8(`\r`), `\n`]

fn (mut r Redis) write_line(data []u8) ! {
	r.write(data)!
	r.write(redisclient.cr_lf_bytes)!
}


fn (mut r Redis) write(data []u8) ! {
	print("lock write:\n$data")
	lock redis_connections{		
		redis_connections[redis_connections.len-1].write(data)!
	}
	println("--OK")
}

fn (mut r Redis) read(size int) ![]u8 {
	print("lock read")
	lock redis_connections{		
		mut res:= redis_connections[redis_connections.len-1].read(size)!
		println("--OK?")
		return res
	}
	panic("bug")
}

fn (mut r Redis) read_line() !string {
	print("lock readln")
	lock redis_connections{		
		mut res:= redis_connections[redis_connections.len-1].read_line()!
		println("--OK?")
		return res
	}
	panic("bug")
}

// write resp value to the redis channel
pub fn (mut r Redis) write_rval(val resp.RValue) ! {
	r.write(val.encode())!
}


// write list of strings to redis challen
fn (mut r Redis) write_cmd(item string) ! {
	a := resp.r_bytestring(item.bytes())
	r.write_rval(a)!
}

// write list of strings to redis challen
fn (mut r Redis) write_cmds(items []string) ! {
	// if items.len==1{
	// 	a := resp.r_bytestring(items[0].bytes())
	// 	r.write_rval(a)!
	// }{
	a := resp.r_list_bstring(items)
	r.write_rval(a)!
	// }	
}

