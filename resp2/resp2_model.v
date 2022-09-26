module resp2

pub struct RString {
pub mut:
	// Redis string
	value string
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

type RValue = RArray | RBString | RError | RInt | RNil | RString

pub const crlf = '\r\n'

const crlf_len = '\r\n'.len