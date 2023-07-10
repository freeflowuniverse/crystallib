module main

import despiegk.crystallib.redisclient
import time
import net

fn conn(c int) ?bool {
	// mut redis := redisclient.get_local_new()?
	// redis.set('test', 'some data')   or { panic("set"+err.str()+"\n"+c.str())}
	// redis.get('test')  or{ panic("get"+err.str()+"\n"+c.str())}
	return true
}

fn conn2(c int) ?bool {
	// mut socket := net.dial_tcp("localhost:6379")?
	// mut socket := net.dial_tcp("/tmp/redis.sock")?

	// socket.set_blocking(true)  or {panic(err)}
	// socket.set_read_timeout(10 * time.second)
	// socket.peer_addr()  or {panic(err)}

	// ONCE THIS WORKS, WE SHOULD TEST NEXT AS well, ENABLE REDIS CLIENT ABOVE

	mut redis := redisclient.get_unixsocket_new() or { panic(err.str() + '\n' + c.str()) }
	redis.set('test', 'some data') or { panic('set' + err.str() + '\n' + c.str()) }
	redis.get('test') or { panic('get' + err.str() + '\n' + c.str()) }
	return true
}

// fn redistest() ? {

// 	mut threads := []thread{}

// 	for c in 0..10000{
// 		//even if going slower does not work?
// 		time.sleep(100*time.millisecond)
// 		println(c)
// 		threads << go conn(c)
// 	}
// 	threads.wait()

// 	println("TEST OK")

// }

fn redistest_nothreads() ? {
	for c in 0 .. 10000 {
		println(c)
		time.sleep(10 * time.millisecond)
		// test with conn as well
		res := conn2(c) or { false }
		if res {
			continue
		}
		println('connect failed $c')
	}

	println('TEST NO THREADS OK')
}

fn main() {
	// THEY BOTH FAIL
	// redistest() or { panic(err) }
	redistest_nothreads() or { panic(err) }
}
