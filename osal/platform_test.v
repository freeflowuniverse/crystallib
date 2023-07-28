module osal


fn test_platform() {
	mut o := new()!

	assert o.platform() != .unknown
}

fn test_cputype() {
	mut o := new()!
	
	assert o.cputype() != .unknown
}