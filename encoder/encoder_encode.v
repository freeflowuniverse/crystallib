module encoder

import time
import encoding.binary as bin

const kb = 1024

pub struct Encoder {
pub mut:
	version u8 = 1 // is important
	data    []u8
}

pub fn encoder_new() Encoder {
	mut e := Encoder{}
	e.add_u8(e.version) // make sure when we decode, we need to check that version corresponds !
	return e
}

// adds u16 length of string in bytes + the bytes
pub fn (mut b Encoder) add_string(data string) {
	if data.len > 64 * encoder.kb {
		panic('string cannot be bigger than 64kb')
	}
	b.add_u16(u16(data.len))
	b.data << data.bytes()
}

// Please note that unlike C and Go, int is always a 32 bit integer.
// We borrow the add_u32() function to handle the encoding of a 32 bit type
pub fn (mut b Encoder) add_int(data int) {
	b.add_u32(u32(data))
}

// add bytes or bytestring
pub fn (mut b Encoder) add_bytes(data []u8) {
	b.add_u32(u32(data.len))
	b.data << data
}

pub fn (mut b Encoder) add_u8(data u8) {
	b.data << data
}

pub fn (mut b Encoder) add_u16(data u16) {
	mut d := []u8{len: 2}
	bin.little_endian_put_u16(mut d, data)
	b.data << d
}

pub fn (mut b Encoder) add_u32(data u32) {
	mut d := []u8{len: 4}
	bin.little_endian_put_u32(mut d, data)
	b.data << d
}

pub fn (mut b Encoder) add_u64(data u64) {
	mut d := []u8{len: 8}
	bin.little_endian_put_u64(mut d, data)
	b.data << d
}

pub fn (mut b Encoder) add_time(data time.Time) {
	b.add_u64(u64(data.unix_time())) // add as epoch time
	b.add_int(data.microsecond)
}

pub fn (mut b Encoder) add_list_string(data []string) {
	if data.len > 64 * encoder.kb {
		panic('list cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len))
	for item in data {
		b.add_string(item)
	}
}

pub fn (mut b Encoder) add_list_int(data []int) {
	if data.len > 64 * encoder.kb {
		panic('list cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // how many items in list
	for item in data {
		b.add_int(item)
	}
}

pub fn (mut b Encoder) add_list_u8(data []u8) {
	if data.len > 64 * encoder.kb {
		panic('list cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // how many items in list
	b.data << data
}

pub fn (mut b Encoder) add_list_u16(data []u16) {
	if data.len > 64 * encoder.kb {
		panic('list cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // how many items in list
	for item in data {
		b.add_u16(item)
	}
}

pub fn (mut b Encoder) add_list_u32(data []u32) {
	if data.len > 64 * encoder.kb {
		panic('list cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // how many items in list
	for item in data {
		b.add_u32(item)
	}
}

pub fn (mut b Encoder) add_list_u64(data []u64) {
	if data.len > 64 * encoder.kb {
		panic('list cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // how many items in list
	for item in data {
		b.add_u64(item)
	}
}

// when complicated hash e.g. map of other object need to serialize each sub object
pub fn (mut b Encoder) add_map_string(data map[string]string) {
	if data.len > 64 * encoder.kb {
		panic('map cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // max nr of items in the map
	for key, val in data {
		b.add_string(key)
		b.add_string(val)
	}
}

// when complicated hash e.g. map of other object need to serialize each sub object
pub fn (mut b Encoder) add_map_bytes(data map[string][]u8) {
	if data.len > 64 * encoder.kb {
		panic('map cannot have more than 64kb items.')
	}
	b.add_u16(u16(data.len)) // max nr of items in the map
	for key, val in data {
		b.add_string(key)
		b.add_bytes(val)
	}
}
