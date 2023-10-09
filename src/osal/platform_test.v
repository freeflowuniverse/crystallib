module osal

fn test_platform() {
	assert platform() != .unknown
}

fn test_cputype() {
	assert cputype() != .unknown
}
