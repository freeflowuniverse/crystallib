module resp2

struct Builder {
mut:
	data []byte
}

pub fn builder_new() Builder {
	return Builder{}
}

pub fn (mut b Builder) add(val RValue) {
	b.data << val.encode()
}

pub fn (val RValue) encode() []byte {
	match val {
		RBString {
			return '\${$val.value.len}\r\n$val.value\r\n'.bytes()
		}
		RInt {
			return ':$val.value\r\n'.bytes()
		}
		RString {
			return '+$val.value\r\n'.bytes()
		}
		RError {
			return '-$val.value\r\n'.bytes()
		}
		RNil {
			return '$-1\r\n'.bytes()
		}
		RArray {
			mut buffer := '*$val.values.len\r\n'.bytes()

			for val2 in val.values {
				buffer << val2.encode()
			}
			return buffer
		}
	}
	panic('cannot find type')
}

pub fn r_nil() RValue {
	return RValue(RNil{})
}

pub fn r_string(value string) RValue {
	return RValue(RString{
		value: value
	})
}

pub fn r_array(value string) RValue {
	return RValue(RArray{})
}

pub fn r_bytestring(value []byte) RValue {
	return RValue(RBString{
		value: value
	})
}

pub fn r_ok() RValue {
	return r_string('OK')
}

pub fn r_int(value int) RValue {
	return RValue(RInt{
		value: value
	})
}

pub fn r_list_int(values []int) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << r_int(v)
	}
	return RValue(RArray{
		values: ll
	})
}

pub fn r_list_string(values []string) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << r_string(v)
	}
	return RValue(RArray{
		values: ll
	})
}

pub fn r_error(value string) RValue {
	return RValue(RError{
		value: value
	})
}

pub fn encode(items []RValue) []byte {
	mut b := builder_new()
	for item in items {
		b.add(item)
	}
	return b.data
}
