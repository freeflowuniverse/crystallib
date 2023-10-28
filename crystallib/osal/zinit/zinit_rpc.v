import net.unix
import json

fn connect() !unix.StreamConn {
	mut s := unix.connect_stream('/var/run/zinit.sock')!
	return s
}

fn shutdown(sc unix.StreamConn) {
	unix.shutdown(sc.sock.handle)
}

// get string from the zinit socket
fn rpc(cmd string) !string {
	mut c := connect()!
	c.write_string(cmd + '\n')!
	mut res := []u8{}
	c.read(mut res)!

	shutdown(c)
	return ''
}

struct ZinitServiceList {
	state string
	body  map[string]string
}

fn list() !map[string]string {
	r := rpc('list')!
	sl := json.decode(ZinitServiceList, r)!
	return sl.body
}

struct ZinitServiceStatus {
	state string
	body  ServiceStatus
}

struct ServiceStatus {
	after  map[string]string
	name   string
	pid    int
	state  string
	target string
}

//{"state":"ok","body":{"after":{"delay":"Success"},"name":"redis","pid":320996,"state":"Running","target":"Up"}}

fn status(name string) !ServiceStatus {
	r := rpc('status ${name}')!
	sl := json.decode(ZinitServiceStatus, r)!
	return sl.body
}
