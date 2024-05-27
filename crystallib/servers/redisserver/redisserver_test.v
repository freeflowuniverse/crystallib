import freeflowuniverse.crystallib.servers.redisserver
import redisclient
import freeflowuniverse.crystallib.ui.console

fn setup() redisserver.RedisSrv {
	return redisserver.listen('0.0.0.0', 5555) or {
		panic("Can't Listen on port with error: ${err}")
	}
}

fn test_run_server() {
	mut redis_server := setup()
	mut main := &redisserver.RedisInstance{}
	for {
		console.print_debug('still looping...')
		mut conn := redis_server.socket.accept() or { continue }
		spawn redisserver.new_client(mut conn, mut main)
		console.print_debug('After GO...')
	}
}

fn client_test() {
	mut redis_client := redisclient.get('localhost:5555') or { panic(err) }
	redis_client.set('b', '5') or { panic(err) }
	val := redis_client.get('b') or { panic(err) }
	assert val == '5'
	console.print_debug('reach here')
}
