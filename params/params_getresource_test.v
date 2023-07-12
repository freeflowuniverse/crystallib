module params

fn test_resource_capacity_in_bytes() {
	text := 'memory: 10KB\ndisk: 10MB\nstorage: 10GB\nssd: 10'
	params := parse(text)!
	assert params.get_storagecapacity_in_bytes('memory')! == 10 * 1024
	assert params.get_storagecapacity_in_bytes('disk')! == 10 * 1024 * 1024
	assert params.get_storagecapacity_in_bytes('storage')! == u64(10) * 1024 * 1024 * 1024
	assert params.get_storagecapacity_in_bytes('ssd')! == 10
}

fn test_resource_capacity_in_bytes_default() {
	text := 'memory: 10KB\ndisk: 10MB\nstorage: 10GB'
	params := parse(text)!
	assert params.get_storagecapacity_in_bytes_default('memory', 10)! == 10 * 1024
	assert params.get_storagecapacity_in_bytes_default('disk', 10)! == 10 * 1024 * 1024
	assert params.get_storagecapacity_in_bytes_default('storage', 10)! == u64(10) * 1024 * 1024 * 1024
	assert params.get_storagecapacity_in_bytes_default('nonexistent', 10)! == 10
}

fn test_resource_capacity_in_gigabytes() {
	text := 'memory: 10KB\ndisk: 10MB\nstorage: 10GB\nssd: 10'
	p := parse(text)!
	assert p.get_storagecapacity_in_gigabytes('memory')! == 1
	assert p.get_storagecapacity_in_gigabytes('disk')! == 1
	assert p.get_storagecapacity_in_gigabytes('storage')! == 10
	assert p.get_storagecapacity_in_gigabytes('ssd')! == 10
}
