module main

import coroutines
import time
import os
import net.http
import net
import io

// This file shows how a basic TCP echo server can be implemented using
// the net module. You can connect to the server by using netcat or telnet,
// in separate shells, for example:
// nc 127.0.0.1 12345
// or
// telnet 127.0.0.1 12345
fn server() {
	mut server := net.listen_tcp(.ip6, ':12345') or {panic(err)}
	laddr := server.addr()or {panic(err)}
	eprintln('Listen on ${laddr} ...')
	for {
		mut socket := server.accept()or {panic(err)}
		spawn handle_client(mut socket)
	}
}

fn handle_client(mut socket net.TcpConn) {
	defer {
		socket.close() or { panic(err) }
	}
	client_addr := socket.peer_addr() or { return }
	eprintln('> new client: ${client_addr}')
	mut reader := io.new_buffered_reader(reader: socket)
	defer {
		unsafe {
			reader.free()
		}
	}
	socket.write_string('server: hello\n') or { return }
	for {
		received_line := reader.read_line() or { return }
		if received_line == '' {
			return
		}
		println('client ${client_addr}: ${received_line}')
		socket.write_string('server: ${received_line}\n') or { return }
	}
}


fn foo1(ch chan string) {
	for {
		m := <-ch or {
			println('channel 1 has been closed')
		}
		println('1 ${m}')
		// coroutines.sleep(1 * time.second)
	}
}

fn foo2(ch chan string) {
	for {
		m := <-ch or {
			println('channel 1 has been closed')
		}
		println('2 ${m}')
		// coroutines.sleep(1 * time.second)
	}
}



fn main() {

	ch1 := chan string{}
	ch2 := chan string{}

	go server()
	go foo1(ch1)
	go foo2(ch2)

	$if is_coroutine ? {
		println('IS COROUTINE=true')
	} $else {
		println('IS COROUTINE=false')
	}
	mut counter:=0
	for {
		counter +=1
		println('hello from MAIN')
		ch1 <- "${counter}"
		ch2 <- "${counter}"
		coroutines.sleep(1000 * time.millisecond)
	}
	println('done')
}