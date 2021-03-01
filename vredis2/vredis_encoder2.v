module vredis2

struct RString {
	value string
}

struct RNum {
	value int
}

struct RSuccess {
	value string
}

struct RError {
	value string
}

struct RNill {
}

struct RList {
	values []RValue
}

type RValue = RError | RList | RNill | RNum | RString | RSuccess

pub fn (value RValue) encode() string {
	match value {
		RString {
			return '\$$value.value.len\r\n$value.value\r\n'
		}
		RNum {
			return ':$value.value\r\n'
		}
		RSuccess {
			return '+$value.value\r\n'
		}
		RError {
			return '-$value.value\r\n'
		}
		RNill {
			return '$-1\r\n'
		}
		RList {
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

// TODO: need to write a decoder

pub fn return_nil() RValue {
	return RValue(RNill{})
}

pub fn return_str(value string) RValue {
	return RValue(RString{
		value: value
	})
}

pub fn return_success(value string) RValue {
	return RValue(RSuccess{
		value: value
	})
}

pub fn return_ok() RValue {
	return return_success('OK')
}

pub fn return_int(value int) RValue {
	return RValue(RNum{
		value: value
	})
}

pub fn return_list_int(values []int) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << return_int(v)
	}
	return RValue(RList{
		values: ll
	})
}

pub fn return_list_string(values []string) RValue {
	mut ll := []RValue{}
	for v in values {
		ll << return_str(v)
	}
	return RValue(RList{
		values: ll
	})
}

pub fn return_error(value string) RValue {
	return RValue(RError{
		value: value
	})
}

// TODO: move to a proper test file
pub fn redis_encode_test() {
	mut rv := RValue(RError{
		value: 'my error'
	})
	println(rv.encode())

	rv = RValue(RList{
		values: [RValue(RError{
			value: 'my error'
		}), RValue(RNum{
			value: 100
		})]
	})
	println(rv.encode())

	rv = return_list_string(['a', 'b', 'c'])
	println(rv.encode())
}
