import net
import io


fn mytest1() {


	mut socket := net.dial_tcp("localhost:6379") or {panic(err)}
	mut reader := io.new_buffered_reader({reader: io.make_reader(socket)})
	//correctly formatted redis string to do a get statement
	redis_cmd := "*2\r\n$3\r\nGET\r\n$4\r\ntest\r\n"

	//takes long time but the result is returned as it needs to be '$-0' if redis empty
	socket.write(redis_cmd.bytes())
	res := io.read_all(reader: socket) or {panic(err)}
	println(res.bytestr())
}

fn mytest2() {

	mut socket := net.dial_tcp("localhost:6379") or {panic(err)}
	mut reader := io.new_buffered_reader({reader: io.make_reader(socket)})
	//correctly formatted redis string to do a get statement
	redis_cmd := "*2\r\n$3\r\nGET\r\n$4\r\ntest\r\n"

	//will give error, think weird utilization of option, but even if we consider this error not to be an error still no return
	//should get something
	socket.write(redis_cmd.bytes())
	// socket.wait_for_read() //doesn't make a change if I put it or not, was just trying
	res2 := reader.read_line() or {panic("error in readline: '$err'")}
	println(res2)
}


// //also does not return anything
// fn mytest3() {

// 	mut socket := net.dial_tcp("localhost:6379") or {panic(err)}
// 	mut reader := io.new_buffered_reader({reader: io.make_reader(socket)})
// 	//correctly formatted redis string to do a get statement
// 	redis_cmd := "*2\r\n$3\r\nGET\r\n$4\r\ntest\r\n"

// 	socket.write(redis_cmd.bytes())
// 	for i in 0..10{
// 		println(socket.read())
// 	}
// }

fn main() {

	// mytest1()
	mytest2()
	// mytest3()
}


