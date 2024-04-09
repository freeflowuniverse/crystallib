module encoderhero

import time


// byte array versions of the most common tokens/chars to avoid reallocations
const null_in_bytes = 'null'

const true_in_string = 'true'

const false_in_string = 'false'

const empty_array = [u8(`[`), `]`]!

const comma_rune = `,`

const colon_rune = `:`

const quote_rune = `"`

const back_slash = [u8(`\\`), `\\`]!

const quote = [u8(`\\`), `"`]!

const slash = [u8(`\\`), `/`]!

const null_unicode = [u8(`\\`), `u`, `0`, `0`, `0`, `0`]!

const ascii_control_characters = ['\\u0000', '\\t', '\\n', '\\r', '\\u0004', '\\u0005', '\\u0006',
	'\\u0007', '\\b', '\\t', '\\n', '\\u000b', '\\f', '\\r', '\\u000e', '\\u000f', '\\u0010',
	'\\u0011', '\\u0012', '\\u0013', '\\u0014', '\\u0015', '\\u0016', '\\u0017', '\\u0018', '\\u0019',
	'\\u001a', '\\u001b', '\\u001c', '\\u001d', '\\u001e', '\\u001f']!

const curly_open_rune = `{`

const curly_close_rune = `}`

const ascii_especial_characters = [u8(`\\`), `"`, `/`]!


// // `Any` is a sum type that lists the possible types to be decoded and used.
// pub type Any = Null
// 	| []Any
// 	| bool
// 	| f32
// 	| f64
// 	| i16
// 	| i32
// 	| i64
// 	| i8
// 	| int
// 	| map[string]Any
// 	| string
// 	| time.Time
// 	| u16
// 	| u32
// 	| u64
// 	| u8

// // Decodable is an interface, that allows custom implementations for decoding structs from JSON encoded values
// pub interface Decodable {
// 	from_json(f Any)
// }

// Decodable is an interface, that allows custom implementations for encoding structs to their string based JSON representations
pub interface Encodable {
	heroscript() string
}

// `Null` struct is a simple representation of the `null` value in JSON.
pub struct Null {
	is_null bool = true
}

pub const null = Null{}

// ValueKind enumerates the kinds of possible values of the Any sumtype.
pub enum ValueKind {
	unknown
	array
	object
	string_
	number
}

// str returns the string representation of the specific ValueKind
pub fn (k ValueKind) str() string {
	return match k {
		.unknown { 'unknown' }
		.array { 'array' }
		.object { 'object' }
		.string_ { 'string' }
		.number { 'number' }
	}
}