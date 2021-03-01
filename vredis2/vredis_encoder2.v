module vredis2

struct RString {
	// Redis string
	value string
}

struct RError {
	// Redis Error
	value string
}

struct RInt {
	// Redis Integer
	value int
}

struct RBString {
	// Redis Bulk String
	value string
}

struct RNill {
	// Redis Nill
}

struct RArray {
	// Redis Array
	values []RValue
}

type RValue = RArray | RBString | RError | RInt | RNill | RString

const crlf = '\r\n'

const crlf_len = '\r\n'.len

pub fn (value RValue) encode() string {
	match value {
		RBString {
			return '\$$value.value.len\r\n$value.value\r\n'
		}
		RInt {
			return ':$value.value\r\n'
		}
		RString {
			return '+$value.value\r\n'
		}
		RError {
			return '-$value.value\r\n'
		}
		RNill {
			return '$-1\r\n'
		}
		RArray {
			mut buffer := '*$value.values.len\r\n'
			for val in value.values {
				response := val.encode()
				buffer = buffer + response
			}
			return buffer
		}
	}
	panic('cannot find type')
}

// Decoder Part
fn decode_str(value string) (RValue, int) {
	crlf_ind := value.index_after(crlf, 0)
	return RValue(RString{
		value: value[1..crlf_ind]
	}), crlf_ind + crlf_len
}

fn decode_error(value string) (RValue, int) {
	crlf_ind := value.index_after(crlf, 0)
	return RValue(RError{
		value: value[1..crlf_ind]
	}), crlf_ind + crlf_len
}

fn decode_int(value string) (RValue, int) {
	crlf_ind := value.index_after(crlf, 0)
	return RValue(RInt{
		value: value[1..crlf_ind].int()
	}), crlf_ind + crlf_len
}

fn decode_bstr(value string) (RValue, int) {
	len := value[1..value.index_after(crlf, 0)].int()
	if len == -1 {
		// Example "$-1\r\n"
		return RValue(RNill{}), value.index_after(crlf, 0) + crlf_len
	}else{
		// Example "$6\r\nfoobar\r\n"
		start := value.index_after(crlf, 0) + crlf_len
		end := start + len
		return RValue(RBString{
			value: value[start .. end]
		}), end + crlf_len
	}
}

fn decode_array(value string) (RValue, int) {
	arr_len := value[1 .. value.index_after(crlf, 0)].int()
	mut decoded_arr := []RValue{}

	mut ptr := value.index_after(crlf, 0) + crlf_len
	for decoded_arr.len < arr_len{
		decoded, ind := decode_helper(value[ptr ..])
		decoded_arr << decoded
		ptr += ind
	}
	return RValue(RArray{
		values: decoded_arr
	}), ptr
}

pub fn decode_helper(str string) (RValue,int) {
	str_bytes := str.bytes()
	mut i := 0
	for i < str_bytes.len {
		if str_bytes[i] == byte(`+`) {
			decoded, ind := decode_str(str[i..str.index_after(crlf, i) + crlf_len])
			i += ind
			// println('This is string: $decoded')
			return decoded, ind
		} else if str_bytes[i] == byte(`-`) {
			decoded, ind := decode_error(str[i..str.index_after(crlf, i) + crlf_len])
			i += ind
			// println('This is error: $decoded')
			return decoded, ind
		} else if str_bytes[i] == byte(`:`) {
			decoded, ind := decode_int(str[i..str.index_after(crlf, i) + crlf_len])
			i += ind
			// println('This is Int : $decoded')
			return decoded, ind
		} else if str_bytes[i] == byte(`$`) {
			decoded, ind := decode_bstr(str[i..])
			i += ind
			// println('This is Bulk string : $decoded')
			return decoded, ind
		} else if str_bytes[i] == byte(`*`) {
			decoded, ind := decode_array(str[i ..])
			i += ind
			// println('This is Array: $decoded')
			return decoded, ind
		} else {
			println('This is not anything')
			return RValue(RNill{}), 0
		}
	}
}

pub fn decode(value string) RValue {
	res, _ := decode_helper(value)
	return res
}

// Builder
pub fn return_str(value string) RValue {
	return RValue(RString{
		value: value
	})
}

pub fn return_error(value string) RValue {
	return RError(RString{
		value: value
	})
}

pub fn return_int(value int) RValue {
	return RValue(RInt{
		value: value
	})
}

pub fn return_ok() RValue {
	return return_str('OK')
}

pub fn return_list_int(values []int) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << return_int(v)
	}
	return RValue(RArray{
		values: ll
	})
}

pub fn return_list_string(values []string) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << return_str(v)
	}
	return RValue(RArray{
		values: ll
	})
}

pub fn return_nil() RValue {
	return RValue(RNill{})
}

// TODO: move to a proper test file
pub fn redis_encode_decode_test() {
	mut rv := RValue(RError{
		value: 'my error'
	})
	println(rv.encode())

	rv = RValue(RArray{
		values: [RValue(RError{
			value: 'my error'
		}), RValue(RInt{
			value: 100
		})]
	})
	println(rv.encode())

	rv = RValue(RArray{
		values: [
			RValue(RInt{
				value: 1
			}),
			RValue(RError{
				value: 'This is error msg'
			}),
			RValue(RString{
				value: 'This is simple string'
			}),
			RValue(RBString{
				value: 'This is a bulk string\r\nTest New Line inside it'
			}),
			RValue(RNill{}),
		]
	})
	println(rv.encode())
	println(decode('+hello\r\n'))
	println(decode('-hello\r\n'))
	println(decode(':100\r\n'))
	println(decode('\$48\r\nThis is a bulk string\r\nTest New Line inside it\r\n')) // TODO: Check again
	println(decode('\$-1\r\n'))
	println(decode('\$0\r\n\r\n'))
	println(decode("*3\r\n:1\r\n:2\r\n:3\r\n"))
	println(decode("*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"))
}
