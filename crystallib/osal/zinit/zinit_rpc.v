module zinit

import net.unix
import json

// TODO: implement all features from https://github.com/threefoldtech/zinit/blob/master/docs/protocol.md
pub struct Client {
	socket_path string = '/var/run/zinit.sock'
}

enum State {
	ok  [json: 'ok']
	error  [json: 'error']
}

struct ZinitResponse {
	state State
	body  string [raw]
}

pub fn new_rpc_client(socket_path string) Client {
	return Client{
		socket_path: socket_path
	}
}

fn (z Client) connect() !&unix.StreamConn {
	mut s := unix.connect_stream(z.socket_path)!
	return s
}

fn close(sc &unix.StreamConn) {
	unix.shutdown(sc.sock.handle)
}

// get string from the zinit socket
fn (z Client) rpc(cmd string) !string {
	mut c := z.connect()!
	c.write_string(cmd + '\n')!
	mut res := []u8{len: 1000, cap: 1000}
	n := c.read(mut res)!
	close(c)
	return res[..n].bytestr()
}

pub fn (z Client) list() !map[string]string {
	response := z.rpc('list')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit list failed: ${decoded_response.body}')
	}

	return json.decode(map[string]string, decoded_response.body)!
}

struct ServiceStatus {
	after  map[string]string
	name   string
	pid    int
	state  string
	target string
}

//{"state":"ok","body":{"after":{"delay":"Success"},"name":"redis","pid":320996,"state":"Running","target":"Up"}}

pub fn (z Client) status(name string) !ServiceStatus {
	response := z.rpc('status ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} status failed: ${decoded_response.body}')
	}

	return json.decode(ServiceStatus, decoded_response.body)!
}

pub fn (z Client) start(name string) ! {
	response := z.rpc('start ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} start failed: ${decoded_response.body}')
	}
}

pub fn (z Client) stop(name string) ! {
	response := z.rpc('stop ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} stop failed: ${decoded_response.body}')
	}
}

pub fn (z Client) forget(name string) ! {
	response := z.rpc('forget ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} forget failed: ${decoded_response.body}')
	}
}

pub fn (z Client) monitor(name string) ! {
	response := z.rpc('monitor ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} monitor failed: ${decoded_response.body}')
	}
}

pub fn (z Client) kill(name string, signal string) ! {
	response := z.rpc('kill ${name} ${signal}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} kill failed: ${decoded_response.body}')
	}
}

pub fn (z Client) shutdown() ! {
	response := z.rpc('shutdown')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit shutdown failed: ${decoded_response.body}')
	}
}

pub fn (z Client) reboot() ! {
	response := z.rpc('reboot')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit reboot failed: ${decoded_response.body}')
	}
}

pub fn (z Client) log() !string {
	response := z.rpc('log')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit log failed: ${decoded_response.body}')
	}

	return decoded_response.body
}
