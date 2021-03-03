module resp2

struct RString {
pub mut:
	// Redis string
	value string
}

struct RError {
pub mut:
	// Redis Error
	value string
}

struct RInt {
pub mut:
	// Redis Integer
	value int
}

struct RBString {
pub mut:
	// Redis Bulk String
	value string
}

struct RNil {
	// Redis Nil
}

struct RArray {
pub mut:
	// Redis Array
	values []RValue
}

type RValue = RArray | RBString | RError | RInt | RNil | RString

const crlf = '\r\n'

const crlf_len = '\r\n'.len
