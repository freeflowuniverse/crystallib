module params


//convert GB, MB, KB to bytes
// e.g. 10 GB becomes bytes in u64
pub fn (params &Params) get_storagecapacity_in_bytes(key string) !u64 {
	valuestr := params.get(key)!
	mut times := 1
	if valuestr.len > 2 && !valuestr[valuestr.len - 2].is_digit()
		&& !valuestr[valuestr.len - 1].is_digit() {
		times = match valuestr[valuestr.len - 2..].to_upper() {
			'GB' {
				1024 * 1024 * 1024
			}
			'MB' {
				1024 * 1024
			}
			'KB' {
				1024
			}
			else {
				0
			}
		}
		if times == 0 {
			return error('not valid: should end with kb, mb or gb')
		}
	}
	return valuestr.u64() * u64(times)
}


pub fn (params &Params) get_storagecapacity_in_bytes_default(key string, defval u64) !u64 {
	if params.exists(key) {
		return params.get_storagecapacity_in_bytes(key)!
	}
	return defval
}