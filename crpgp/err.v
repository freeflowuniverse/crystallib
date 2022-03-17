module crpgp

fn construct_error() ?int {
	// todo: call the func to get the error length
	err_buf := unsafe { malloc(1024) }
	C.error_message(err_buf, 1024)
	str := unsafe { cstring_to_vstring(err_buf) }
	unsafe { free(err_buf) }
	return error(str)
}
