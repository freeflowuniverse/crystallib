module redisclientcore

import redisclient
import appsbox.redisapp


// get a new one guaranteed, need for threads
pub fn get() &redisclient.Redis {
	// tcpport := 7777
	// mut r := Redis{
	// 	addr: '/tmp/redis_${tcpport}.sock'
	// }
	mut r := redisclient.get('localhost:6379') or {
		println("$err")
		//make sure redis starts
		_ := redisapp.client_local_get()or { panic("cannot start/build a redis server.\n$err")}
		return redisclient.get('localhost:7777') or { panic("cannot connect redis to localhost:6379 and localhost:7777.\n$err")}
	}
	return r
}

// pub fn get_unixsocket_new() ?&Redis {
// 	//make sure redis starts
// 	_ := redisapp.client_local_get()?
// 	mut r := Redis{
// 		addr: '/tmp/redis.sock'
// 	}
// 	r.socket_connect() ?
// 	return &r
// }

// pub fn get_unixsocket() ?&redisclient.Redis {
// 	mut r := redisclient.get('/tmp/redis-default.sock')or {
// 		//make sure redis starts
// 		_ := redisapp.client_local_get()or { panic("cannot start/build a redis server.\n$err")}
// 		return redisclient.get('localhost:7777') or { panic("cannot connect redis to localhost:6379 and localhost:7777")}
// 	}
// 	return r
// }
