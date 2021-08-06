import time
import despiegk.crystallib.examples.ourserver

fn main() {
	go ourserver.server_start()
	ourserver.tcp_port_test('127.0.0.1', ourserver.tcp_server_port, 5) or {
		panic('could not connect to server')
	}
	for i in 0 .. 50 {
		go ourserver.sender(i)
	}
	time.sleep(100)
}
