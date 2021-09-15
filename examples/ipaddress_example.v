import builder

fn main() {
	mut ip := builder.ipaddress_new('8.8.8.8') or { panic(err) }

	assert ip.cat == builder.IpAddressType.ipv4
	assert ip.addr == '8.8.8.8'
	assert ip.port == 0

	ip = builder.ipaddress_new('192.186.90.90:80') or { panic(err) }
	assert ip.cat == builder.IpAddressType.ipv4
	assert ip.addr == '192.186.90.90'
	assert ip.port == 80

	ip = builder.ipaddress_new('2001:4860:4860::8888') or { panic(err) }
	assert ip.cat == builder.IpAddressType.ipv6
	assert ip.addr == '2001:4860:4860'
	assert ip.port == 8888

	ip = builder.ipaddress_new('2001:4860:4860') or { panic(err) }
	assert ip.cat == builder.IpAddressType.ipv6
	assert ip.addr == '2001:4860:4860'
	assert ip.port == 0
}
