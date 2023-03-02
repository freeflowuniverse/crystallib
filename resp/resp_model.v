module resp

pub struct RString {
pub mut:
	// Redis string
	value string
}

fn (v RString) str() string {
	return v.value
}

pub struct RError {
pub mut:
	// Redis Error
	value string
}

pub struct RInt {
pub mut:
	// Redis Integer
	value int
}

fn (v RInt) int() int {
	return v.value
}

fn (v RInt) u32() u32 {
	return u32(v.value)
}

pub struct RBString {
pub mut:
	// Redis Bulk String
	value []u8
}

pub struct RNil {
	// Redis Nil
}

pub struct RArray {
pub mut:
	// Redis Array
	values []RValue
}

fn (v RArray) intlist() []int {
	mut res := []int{}
	for item in v.values {
		res << item.int()
	}
	return res
}

fn (v RArray) u32list() []u32 {
	mut res := []u32{}
	for item in v.values {
		res << item.u32()
	}
	return res
}

fn (v RArray) strlist() []string {
	mut res := []string{}
	for item in v.values {
		res << item.strget()
	}
	return res
}

type RValue = RArray | RBString | RError | RInt | RNil | RString

pub fn (v RValue) int() int {
	match v {
		RInt {
			return v.int()
		}
		// RArray{
		// 	return v.int()
		// }
		else {
			panic('could not find type')
		}
	}
}

pub fn (v RValue) u32() u32 {
	match v {
		RInt {
			return v.u32()
		}
		// RArray{
		// 	return v.u32()
		// }
		else {
			panic('could not find type')
		}
	}
}

pub fn (v RValue) strget() string {
	match v {
		RInt {
			return v.str()
		}
		// RArray{
		// 	return v.str()
		// }
		RString {
			return v.str()
		}
		else {
			panic('could not find type')
		}
	}
}

pub fn (v RValue) strlist() []string {
	match v {
		RArray {
			return v.strlist()
		}
		else {
			panic('could not find type')
		}
	}
}

pub fn (v RValue) u32list() []u32 {
	match v {
		RArray {
			return v.u32list()
		}
		else {
			panic('could not find type')
		}
	}
}

pub const crlf = '\r\n'

const crlf_len = '\r\n'.len
