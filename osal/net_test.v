module osal

fn test_ipaddr_pub_get() {
	ipaddr := ipaddr_pub_get()!
	assert ipaddr != ''
}

fn test_ping() {
	assert ping(address: '127.0.0.1', count: 1) == .ok
}

fn test_ping_timeout() ! {
	assert ping(address: '192.168.145.154', count: 5, timeout: 1) == .timeout
}

fn test_ping_unknownhost() ! {
	assert ping(address: '12.902.219.1', count: 5, timeout: 1) == .unknownhost
}