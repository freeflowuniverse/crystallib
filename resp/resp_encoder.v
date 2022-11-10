module resp

pub struct Builder {
pub mut:
	data []u8
}

pub fn builder_new() Builder {
	return Builder{}
}

pub fn (mut b Builder) add(val RValue) {
	b.data << val.encode()
}

// add the data at the beginning
pub fn (mut b Builder) prepend(val RValue) {
	b.data << val.encode()
	b.data << b.data
}

pub fn (val RValue) encode() []u8 {
	match val {
		RBString {
			return '\$$val.value.len\r\n$val.value.bytestr()\r\n'.bytes()
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

pub fn r_bytestring(value []u8) RValue {
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

// might be that this does no exist for redis, lets check
// if it doesn't exist lets create it
pub fn r_float(value f64) RValue {
	panic('not implemented')
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

pub fn r_list_bstring(values []string) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << r_bytestring(v.bytes())
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

// encode list of RArray | RBString | RError | RInt | RNil | RString
// bytestring is result
pub fn encode(items []RValue) []u8 {
	mut b := builder_new()
	for item in items {
		b.add(item)
	}
	return b.data
}
