module redisclient

import resp

pub fn (mut r Redis) get_response() ?resp.RValue {
	line := r.read_line()?

	if line.starts_with('-') {
		return resp.RError{
			value: line[1..]
		}
	}
	if line.starts_with(':') {
		return resp.RInt{
			value: line[1..].int()
		}
	}
	if line.starts_with('+') {
		return resp.RString{
			value: line[1..]
		}
	}
	if line.starts_with('$') {
		mut bulkstring_size := line[1..].int()
		if bulkstring_size == -1 {
			return resp.RNil{}
		}
		if bulkstring_size == 0 {
			// extract final \r\n and not reading
			// any payload
			r.read_line()?
			return resp.RString{
				value: ''
			}
		}
		// read payload
		buffer := r.read(bulkstring_size) or { panic(err) }
		// extract final \r\n
		r.read_line()?
		// println("readline result:'$buffer.bytestr()'")
		return resp.RBString{
			value: buffer
		} // TODO: won't support binary (afaik), need to fix		
	}

	if line.starts_with('*') {
		mut arr := resp.RArray{
			values: []resp.RValue{}
		}
		items := line[1..].int()

		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_response()?
			arr.values << value
		}

		return arr
	}

	return error('unsupported response type')
}

// TODO: needs to use the resp library

pub fn (mut r Redis) get_int() ?int {
	line := r.read_line()?
	if line.starts_with(':') {
		return line[1..].int()
	} else {
		return error("Did not find int, did find:'$line'")
	}
}

pub fn (mut r Redis) get_list_int() ?[]int {
	line := r.read_line()?
	mut res := []int{}

	if line.starts_with('*') {
		items := line[1..].int()
		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_int()?
			res << value
		}
		return res
	} else {
		return error("Did not find int, did find:'$line'")
	}
}

pub fn (mut r Redis) get_list_str() ?[]string {
	line := r.read_line()?
	mut res := []string{}

	if line.starts_with('*') {
		items := line[1..].int()
		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_string()?
			res << value
		}
		return res
	} else {
		return error("Did not find int, did find:'$line'")
	}
}

pub fn (mut r Redis) get_string() ?string {
	line := r.read_line()?
	if line.starts_with('+') {
		// println("getstring:'${line[1..]}'")
		return line[1..]
	}
	if line.starts_with('$') {
		r2 := r.get_bytes_from_line(line)?
		return r2.bytestr()
	} else {
		return error("Did not find string, did find:'$line'")
	}
}

pub fn (mut r Redis) get_string_nil() ?string {
	r2 := r.get_bytes_nil()?
	return r2.bytestr()
}

pub fn (mut r Redis) get_bytes_nil() ?[]u8 {
	line := r.read_line()?
	if line.starts_with('+') {
		return line[1..].bytes()
	}
	if line.starts_with('$') {
		return r.get_bytes_from_line(line)
	} else {
		return error("Did not find string or nil, did find:'$line'")
	}
}

pub fn (mut r Redis) get_bool() ?bool {
	i := r.get_int()?
	return i == 1
}

pub fn (mut r Redis) get_bytes() ?[]u8 {
	line := r.read_line()?
	if line.starts_with('$') {
		return r.get_bytes_from_line(line)
	} else {
		return error("Did not find bulkstring, did find:'$line'")
	}
}

fn (mut r Redis) get_bytes_from_line(line string) ?[]u8 {
	mut bulkstring_size := line[1..].int()
	if bulkstring_size == -1 {
		return none
	}
	if bulkstring_size == 0 {
		// extract final \r\n, there is no payload
		r.read_line()?
		return []
	}
	// read payload
	buffer := r.read(bulkstring_size)?
	// extract final \r\n
	r.read_line()?
	return buffer
}
