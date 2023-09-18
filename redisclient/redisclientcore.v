module redisclient

[params]
pub struct RedisURL {
	address string = '127.0.0.1'
	port    u16    = 6379
}

pub fn core_get(url RedisURL) !Redis {
	lock redis_connections{		
		println("lock redis")
		if redis_connections.len==0{
			new(['${url.address}:${url.port}'])!
		}
	}
	println("unlock redis")
	mut r := Redis{}
	return r
}
