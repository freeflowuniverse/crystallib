module ipaddress

fn test_ping() {
	mut addr := IPAddress{
		addr: '127.0.0.1'
	}
	assert addr.ping(timeout: 3)
	assert addr.port == 0
}

fn test_ping_fails() {
	mut addr := IPAddress{
		addr: '22.22.22.22'
	}
	assert addr.ping(timeout: 3) == false
	assert addr.port == 0
	assert addr.addr == "22.22.22.22"
}


fn test_ipv4a() {
	mut addr := new('22.22.22.22') or { panic(err) }
	assert addr.cat==.ipv4
	assert addr.port == 0
	assert addr.addr == "22.22.22.22"
}

fn test_ipv4b() {
	mut addr := new('22.22.22.22:33') or { panic(err) }
	assert addr.addr=="22.22.22.22"
	assert addr.cat==.ipv4
	assert addr.port == 33
}

fn test_ipv6() {
	mut addr := new('202:6a34:cd78:b0d7:5521:8de7:218e:6680') or { panic(err) }
	assert addr.cat==.ipv6
	assert addr.port == 0
	assert addr.ping(timeout: 3) == false
}

fn test_ipv6b() {
	mut addr := new('[202:6a34:cd78:b0d7:5521:8de7:218e:6680]') or { panic(err) }
	assert addr.cat==.ipv6
	assert addr.port == 0
}

fn test_ipv6c() {
	mut addr := new('[202:6a34:cd78:b0d7:5521:8de7:218e:6680]:22 ') or { panic(err) }
	assert addr.cat==.ipv6
	assert addr.port ==22
	assert addr.addr =="202:6a34:cd78:b0d7:5521:8de7:218e:6680"
}
