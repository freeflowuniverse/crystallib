module zinit

import net.unix
import json

// TODO: implement all features from https://github.com/threefoldtech/zinit/blob/master/docs/protocol.md

enum State {
	ok  [json: 'ok']
	error  [json: 'error']
}

struct ZinitResponse {
	state State
	body  string [raw]
}

fn connect() !&unix.StreamConn {
	mut s := unix.connect_stream('/var/run/zinit.sock')!
	return s
}

fn close(sc &unix.StreamConn) {
	unix.shutdown(sc.sock.handle)
}

// get string from the zinit socket
fn rpc(cmd string) !string {
	mut c := connect()!
	c.write_string(cmd + '\n')!
	mut res := []u8{len: 1000, cap: 1000}
	n := c.read(mut res)!
	close(c)
	return res[..n].bytestr()
}

pub fn list() !map[string]string {
	response := rpc('list')!
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

pub fn status(name string) !ServiceStatus {
	response := rpc('status ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} status failed: ${decoded_response.body}')
	}

	return json.decode(ServiceStatus, decoded_response.body)!
}

pub fn start(name string) ! {
	response := rpc('start ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} start failed: ${decoded_response.body}')
	}
}

pub fn stop(name string) ! {
	response := rpc('stop ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} stop failed: ${decoded_response.body}')
	}
}

pub fn forget(name string) ! {
	response := rpc('forget ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} forget failed: ${decoded_response.body}')
	}
}

pub fn monitor(name string) ! {
	response := rpc('monitor ${name}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} monitor failed: ${decoded_response.body}')
	}
}

pub fn kill(name string, signal string) ! {
	response := rpc('kill ${name} ${signal}')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('service ${name} kill failed: ${decoded_response.body}')
	}
}

pub fn shutdown() ! {
	response := rpc('shutdown')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit shutdown failed: ${decoded_response.body}')
	}
}

pub fn reboot() ! {
	response := rpc('reboot')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit reboot failed: ${decoded_response.body}')
	}
}

pub fn log() !string {
	response := rpc('log')!
	decoded_response := json.decode(ZinitResponse, response)!
	if decoded_response.state == .error {
		return error('zinit log failed: ${decoded_response.body}')
	}

	return decoded_response.body as string
}
