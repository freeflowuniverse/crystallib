module resp2

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

pub fn r_ok(value string) RValue {
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
