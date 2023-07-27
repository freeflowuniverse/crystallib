module osal

fn test_done_set() ! {
	mut o := new()!

	o.done_set("mykey", "myvalue")!
	assert o.done_exists("mykey")
	assert o.done_get("mykey")! == "myvalue"
	assert o.done_get_str("mykey") == "myvalue"
	assert o.done_get_int("mykey") == 0
	o.done_print()!
	o.done_reset()!
}
