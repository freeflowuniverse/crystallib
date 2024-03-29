module redisclient

@[params]
pub struct RedisURL {
	address string = '127.0.0.1'
	port    u16    = 6379
}

pub fn get_redis_url(url string) !RedisURL {
	if !url.contains(':') {
		return error('url doesnt contain port')
	} else {
		return RedisURL{
			address: url.all_before_last(':')
			port: url.all_after_last(':').u16()
		}
	}
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

	mut r := Redis{}
	return r
}
