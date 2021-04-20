import despiegk.crystallib.redisserver
import despiegk.crystallib.redisclient
import time

fn setup() redisserver.RedisSrv {
	return redisserver.listen('0.0.0.0', 5555) or { panic("Can't Listen on port with error: $err") }
}

fn test_run_server() {
	mut redis_server := setup()
	mut main := &redisserver.RedisInstance{}
	for {
		println('still looping...')
		mut conn := redis_server.socket.accept() or { continue }
		go redisserver.new_client(mut conn, mut main)
		println('After GO...')
	}
}

fn client_test() {
	mut redis_client := redisclient.connect('localhost:5555') or { panic(err) }
	redis_client.set('b', '5') or { panic(err) }
	val := redis_client.get('b') or { panic(err) }
	assert val == '5'
	println('reach here')
}

fn main() {
	go test_run_server()
	println('server started...')
	time.sleep(2)
	client_test() // FIXME
	return
}
