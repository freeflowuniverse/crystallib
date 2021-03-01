module ipaddress

fn test_ping() {
	mut addr := IPAddress{
		addr: '127.0.0.1'
	}
	assert addr.ping({})

	mut addr2 := IPAddress{
		addr: '22.22.22.22'
	}
	assert addr2.ping({}) == false
}

fn test_ipv6() {
	_ := ipaddress_new('202:6a34:cd78:b0d7:5521:8de7:218e:6680') or { panic(err) }

	// assert ipaddr.ping({}) == true
}
