module resp2

// 	mut r := io.new_buffered_reader(reader: io.make_reader(conn))
// 	for {
// 		l := r.read_line() or { break }
// 		println('$l')
// 		// Make it nice and obvious that we are doing this line by line
// 		time.sleep(100 * time.millisecond)
// 	}
// }

pub fn (mut r StringLineReader) get_response() ?RValue {
	line_ := r.read_line() ?
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
			r.read_line() ?
			return RString{
				value: ''
			}
		}
		// read payload
		buffer := r.read(bulkstring_size) or { panic(err) }
		// extract final \r\n
		r.read_line() ?
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
			value := r.get_response() ?
			arr.values << value
		}

		return arr
	}

	return error('unsupported response type')
}

pub fn decode(data []byte) ?[]RValue {
	mut r := new_line_reader(data)
	mut res := []RValue{}
	for {
		v := r.get_response() or { break }
		res << v
	}
	return res
}
