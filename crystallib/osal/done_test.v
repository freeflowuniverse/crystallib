module osal

fn test_done_set() ! {
	done_set('mykey', 'myvalue')!
	assert done_exists('mykey')
	assert done_get('mykey')! == 'myvalue'
	assert done_get_str('mykey') == 'myvalue'
	assert done_get_int('mykey') == 0
	done_print()!
	done_reset()!
}
