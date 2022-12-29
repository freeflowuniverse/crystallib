module encoder
import time

pub struct Encoder {
pub mut:
	version: u8=1 //is important
	data []u8
}

pub fn encoder_new() Encoder {
	mut e:=Encoder{}
	e.add_u8(e.version) //make sure when we decode, we need to check that version corresponds !
}


//adds u16 length of string in bytes + the bytes
pub fn (mut b Encoder) add_string(data string) {
	if data.len>64000{
		panic("string cannot be bigger than 64kb")
	}
	b.add_u16(data.len.u16())
	b.data << data.bytes()
}

//add bytes or bytestring
pub fn (mut b Encoder) add_bytes(data []u8) {
	b.add_u32(data.len.u32())
	b.data << data
}

pub fn (mut b Encoder) add_u8(data u8) {
	little_endian_put_u8(mut b.data, data.len.u8())
}

pub fn (mut b Encoder) add_u16(data u16) {
	little_endian_put_u16(mut b.data, data.len.u16())
}

pub fn (mut b Encoder) add_u32(data u32) {
	little_endian_put_u32(mut b.data, data.len.u32())
}

pub fn (mut b Encoder) add_time(data time.Time) {
	little_endian_put_u32(mut b.data, data.unix()) //TODO, add as epoch time
}


pub fn (mut b Encoder) add_list_string(data []string) {
	if data.len>64000{
		panic("list cannot have more than 64000 items.")
	}
	b.add_u16(data.len.u16())
	for item in data{
		v.add_string(item)
	}
}

pub fn (mut b Encoder) add_list_int(data []int) {
	if data.len>64000{
		panic("list cannot have more than 64000 items.")
	}
	b.add_u16(data.len.u16())//how many items in list
	for item in data{
		v.add_int(item)
	}
}

pub fn (mut b Encoder) add_list_u8(data []u8) {
	if data.len>64000{
		panic("list cannot have more than 64000 items.")
	}
	b.add_u16(data.len.u16())//how many items in list
	for item in data{
		v.add_u8(item)
	}
}

pub fn (mut b Encoder) add_list_u16(data []u16) {
	if data.len>64000{
		panic("list cannot have more than 64000 items.")
	}
	b.add_u16(data.len.u16())//how many items in list
	for item in data{
		v.add_u16(item)
	}
}

pub fn (mut b Encoder) add_list_u32(data []u32) {
	if data.len>64000{
		panic("list cannot have more than 64000 items.")
	}
	b.add_u16(data.len.u16())//how many items in list
	for item in data{
		v.add_u32(item)
	}
}

//when complicated hash e.g. map of other object need to serialize each sub object
pub fn (mut b Encoder) add_map_bytes(data map[string][]u8) {
	b.add_u16(data.len.u16()) //max nr of items in the map
	for key,val in data{
		b.add_u16(key.len.u16())
		v.add_string(key)
		b.add_u16(val.len.u16())
		v.add_bytes(val)
	}
}

//when complicated hash e.g. map of other object need to serialize each sub object
pub fn (mut b Encoder) add_map_string(data map[string]string) {
	b.add_u16(data.len.u16()) //max nr of items in the map
	for key,val in data{
		b.add_u16(key.len.u16())
		v.add_string(key)
		b.add_u16(val.len.u16())
		v.add_string(val)
	}
}