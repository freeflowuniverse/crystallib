module ipaddress

fn test_ping() {
	mut addr := IPAddress{
		addr: '127.0.0.1'
	}
	assert addr.ping(timeout: 3)
}

fn test_ping_fails() {
	mut addr := IPAddress{
		addr: '22.22.22.22'
	}
	assert addr.ping(timeout: 3) == false
}

fn test_ipv6() {
	mut addr := ipaddress_new('202:6a34:cd78:b0d7:5521:8de7:218e:6680') or { panic(err) }

	assert addr.ping(timeout: 3) == false
}
