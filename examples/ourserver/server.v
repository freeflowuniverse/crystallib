module ourserver
import net
import sync
import time

struct Controller {
mut:
	x   int // share data
	mtx &sync.Mutex
	y   map[string]string
	queue []string
}

fn (mut controller Controller) handle_conn(_c net.TcpConn, instance int) {
	mut c := _c
	for {
		mut buf := []byte{len: 100, init: 0}
		read := c.read(mut buf) or {
			println('Server: connection dropped')
			return
		}
		// println("msg for")
		controller.mtx.m_lock()
		// read/modify/write b.x
		controller.y["$instance"]=buf.bytestr()
		controller.queue << buf.bytestr()
		controller.mtx.unlock()

		// buf.bytestr()
		// println(buf.bytestr())
		// c.write(buf[..read]) or {
		// 	println('Server: connection dropped')
		// 	return
		// }
	}
}

fn (mut controller Controller) reader() {
	for {
		time.sleep(1)
		controller.mtx.m_lock()
		for x in controller.queue{
			println(x)
		}
		controller.queue=[]
		// println(controller.y)
		controller.mtx.unlock()

		// buf.bytestr()
		// println(buf.bytestr())
		// c.write(buf[..read]) or {
		// 	println('Server: connection dropped')
		// 	return
		// }
	}
}



// struct Controller{
// 	mut:
// 		db map[string]string
// 		channels []chan string
// }



// fn echo_server(l net.TcpListener) ? {
pub fn server_start() ? {	
	println("server start")
	l := net.listen_tcp(tcp_server_port) or {
		panic(err)
	}

	mut controller := &Controller{mtx:sync.new_mutex()}

	// mut x:=0
	mut ret := 0

	// mut mainchannel := chan int{}
	//{cap: 100} 

	go controller.reader()

	mut instance := 0 

	for {
		new_conn := l.accept() or {
			continue
		}

		instance++

		//how can I create a channel per connection & keep a connection open with the mother?
		// controller.channels << chan string{cap: 100} 
		// go handle_conn(new_conn,controller.channels[controller.channels.len-1]) //thread per user
		go controller.handle_conn(new_conn,instance) //thread per user

		// x++

		// ret <-mainchannel
		
		// for ch in controller.channels{
		// 	ret <-ch
		// 	println("MAIN: $ret")
		// }

	}
	return none
}


