module redisclient

[params]
pub struct RedisURL {
	address string = '127.0.0.1'
	port    u16    = 6379
}

pub fn core_get(url RedisURL) !Redis {
	mut r := get('${url.address}:${url.port}')!
	return r
}
