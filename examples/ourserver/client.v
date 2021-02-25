module ourserver

// import io
import net
import time
// import strings


pub fn tcp_port_test(addr string , port int, timeout int)?{

	mut start:= time.now()

	for i in 0..999999{
		if i>1 {
			time.sleep_ms(10)
		}
		if time.now().unix_time() > start.unix_time() + timeout{
			break
		}
		if client := net.dial_tcp('$addr:$port'){
			if r := client.peer_ip(){
				print(r)
				return
			}else{
				continue
			}
		}else{
			continue
		}		
		
	}
	return error("could not connect to $addr:$port")
		

}

// fn setup() (net.TcpListener, net.TcpConn, net.TcpConn) {
// 	server := net.listen_tcp(server_port) or {
// 		panic(err)
// 	}
// 	mut socket := server.accept() or {
// 		panic(err)
// 	}
// 	return server, socket
// }

// // server, socket := setup()
// // mut reader := io.new_buffered_reader({
// // 	reader: io.make_reader(client)
// // })


pub fn sender(instance int) ? {
	mut c := net.dial_tcp('127.0.0.1:$tcp_server_port')?
	defer {
		println("close sender")
		c.close() or { }
	}
	for i in 0..100 {
		time.sleep_ms(i*10)
		// println("sender:$instance run:$i")
		data := 'jo $instance ($i)\n'
		c.write_str(data)?
	}
	// mut buf := []byte{len: 4096}
	// read := c.read(mut buf)?
	// assert read == data.len
	// for i := 0; i < read; i++ {
	// 	assert buf[i] == data[i]
	// }
	// println('Got "$buf.bytestr()"')
	// return none
}


// fn echo() ? {
// 	mut c := net.dial_tcp('127.0.0.1:$tcp_server_port')?
// 	defer {
// 		c.close() or { }
// 	}
// 	data := 'Hello from vlib/net!'
// 	c.write_str(data)?
// 	mut buf := []byte{len: 4096}
// 	read := c.read(mut buf)?
// 	assert read == data.len
// 	for i := 0; i < read; i++ {
// 		assert buf[i] == data[i]
// 	}
// 	println('Got "$buf.bytestr()"')
// 	return none
// }


// go echo_server(l)
// time.sleep(0.1)
// go sender()

// //now call the server
// echo() or {
// 	panic(err)
// }
// l.close() or { }
