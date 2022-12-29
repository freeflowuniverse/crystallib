module resp

// 	mut r := io.new_buffered_reader(reader: io.make_reader(conn))
// 	for {
// 		l := r.read_line() or { break }
// 		println('$l')
// 		// Make it nice and obvious that we are doing this line by line
// 		time.sleep(100 * time.millisecond)
// 	}
// }

pub fn (mut r StringLineReader) get_response() !RValue {
	line_ := r.read_line()
	line := line_.bytestr()

	if line.starts_with('-') {
		return RError{
			value: line[1..]
		}
	}
	if line.starts_with(':') {
		return RInt{
			value: line[1..].int()
		}
	}
	if line.starts_with('+') {
		return RString{
			value: line[1..]
		}
	}
	if line.starts_with('$') {
		mut bulkstring_size := line[1..].int()
		if bulkstring_size == -1 {
			return RNil{}
		}
		if bulkstring_size == 0 {
			// extract final \r\n and not reading
			// any payload
			r.read_line()
			return RString{
				value: ''
			}
		}
		// read payload
		buffer := r.read(bulkstring_size) or { panic(err) }
		// extract final \r\n
		r.read_line()
		return RBString{
			value: buffer
		} // FIXME: won't support binary (afaik)
	}

	if line.starts_with('*') {
		mut arr := RArray{
			values: []RValue{}
		}
		items := line[1..].int()

		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_response()!
			arr.values << value
		}

		return arr
	}

	return error('unsupported response type')
}

pub fn decode(data []u8) ![]RValue {
	mut r := new_line_reader(data)
	mut res := []RValue{}
	for {
		v := r.get_response() or { break }
		res << v
	}
	return res
}

pub fn (mut r StringLineReader) get_int() !int {
	line_ := r.read_line()
	line := line_.bytestr()
	if line.starts_with(':') {
		return line[1..].int()
	} else {
		return error("Did not find int, did find:'${line}'")
	}
}

pub fn (mut r StringLineReader) get_list_int() ![]int {
	line_ := r.read_line()
	line := line_.bytestr()
	mut res := []int{}

	if line.starts_with('*') {
		items := line[1..].int()
		// proceed each entries, they can be of any types
		for _ in 0 .. items {
			value := r.get_int()!
			res << value
		}
		return res
	} else {
		return error("Did not find int, did find:'${line}'")
	}
}

pub fn (mut r StringLineReader) get_string() !string {
	line_ := r.read_line()
	line := line_.bytestr()
	if line.starts_with('+') {
		return line[1..]
	} else {
		return error("Did not find string, did find:'${line}'")
	}
}

pub fn (mut r StringLineReader) get_bool() !bool {
	i := r.get_int()!
	return i == 1
}

pub fn (mut r StringLineReader) get_bytes() ![]u8 {
	line_ := r.read_line()
	line := line_.bytestr()
	if line.starts_with('$') {
		mut bulkstring_size := line[1..].int()
		if bulkstring_size == -1 {
			return []u8{}
		}
		if bulkstring_size == 0 {
			// extract final \r\n and not reading
			// any payload
			r.read_line()
			return ''.bytes()
		}
		// read payload
		buffer := r.read(bulkstring_size)!
		// extract final \r\n
		return buffer
	} else {
		return error("Did not find bulkstring, did find:'${line}'")
	}
}

pub fn get_redis_value(rv RValue) string {
	if rv is RArray || rv is RNil {
		rv_type := rv.type_name()
		panic("Can't get value for ${rv_type}")
	}
	return match rv {
		RInt {
			rv.value.str()
		}
		RString, RError {
			rv.value
		}
		RBString {
			rv.value.bytestr()
		}
		else {
			''
		}
	}
}

pub fn get_redis_value_by_index(rv RValue, i int) string {
	if rv !is RArray {
		panic('This functions used with RArray only, use get_value instead')
	}
	return match rv {
		RArray {
			get_redis_value(rv.values[i])
		}
		else {
			''
		}
	}
}

pub fn get_redis_array(rv RValue) []RValue {
	if rv !is RArray {
		panic('This functions used with RArray only, use get_value instead')
	}
	return match rv {
		RArray {
			rv.values
		}
		else {
			[]RValue{}
		}
	}
}

pub fn get_redis_array_len(rv RValue) int {
	if rv !is RArray {
		panic('This functions used with RArray only')
	}
	return match rv {
		RArray {
			rv.values.len
		}
		else {
			result := -1
			result
		}
	}
}

pub fn get_array_value(rv RValue, index int) string {
	return get_redis_value(get_redis_array(rv)[index])
}
