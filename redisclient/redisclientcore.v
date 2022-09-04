module redisclient

import freeflowuniverse.crystallib.redisclient
// import freeflowuniverse.crystallib.appsbox.redisapp

pub fn core_get() &redisclient.Redis {
	// tcpport := 7777
	// mut r := Redis{
	// 	addr: '/tmp/redis_${tcpport}.sock'
	// }
	mut r := redisclient.get('127.0.0.1:6379') or {
		panic(err)
		// println('$err')
		// make sure redis starts
		// _ := redisapp.client_local_get() or { panic('cannot start/build a redis server.\n$err') }
		// return redisclient.get('localhost:7777') or {
		// 	panic('cannot connect redis to localhost:6379 and localhost:7777.\n$err')
		// }
	}
	return r
}

// make sure that we don't reuse same socket, we need to create new one in each subprocess
// pub fn reset() {
// 	// redisclient.reset()
// }

// pub fn get_unixsocket_new() ?&redisclient.Redis {
// 	// 	//make sure redis starts
// 	_ := redisapp.client_local_get()?
// 	mut r := redisclient.Redis{
// 		addr: '/tmp/redis.sock'
// 	}
// 	r.socket_connect()?
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
