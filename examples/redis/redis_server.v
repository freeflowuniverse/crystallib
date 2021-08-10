import vredis2

fn redis_server() {
	println('Listening')

	srv := vredis2.listen('0.0.0.0', 5555) or { panic(err) }
	mut main := &vredis2.RedisInstance{}

	for {
		conn := srv.socket.accept() or { continue }
		go vredis2.new_client(conn, mut main)
	}
}

fn main() {
	redis_server()
}
