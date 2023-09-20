module redisclient

[params]
pub struct RedisURL {
	address string = '127.0.0.1'
	port    u16    = 6379
}

pub fn core_get(url RedisURL) !Redis {
	mut connection_exists := false // if any redis connection exists that can be used

	lock redis_connections {
		if redis_connections.len > 0 {
			connection_exists = true
		}
	}
	if !connection_exists {
		new(['${url.address}:${url.port}'])!
	}
	println('unlock redis')
	mut r := Redis{}
	return r
}
