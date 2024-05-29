module encoder

import time
import math
import freeflowuniverse.crystallib.ui.console

fn test_string() {
	mut e := new()
	e.add_string('a')
	e.add_string('bc')
	assert e.data == [u8(1), 0, 97, 2, 0, 98, 99]

	mut d := decoder_new(e.data)
	assert d.get_string() == 'a'
	assert d.get_string() == 'bc'
}

fn test_int() {
	mut e := new()
	e.add_int(math.min_i32)
	e.add_int(math.max_i32)
	assert e.data == [u8(0x00), 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0x7f]

	mut d := decoder_new(e.data)
	assert d.get_int() == math.min_i32
	assert d.get_int() == math.max_i32
}

fn test_bytes() {
	sb := 'abcdef'.bytes()

	mut e := new()
	e.add_list_u8(sb)
	assert e.data == [u8(6), 0, 97, 98, 99, 100, 101, 102]

	mut d := decoder_new(e.data)
	assert d.get_list_u8() == sb
}

fn test_u8() {
	mut e := new()
	e.add_u8(math.min_u8)
	e.add_u8(math.max_u8)
	assert e.data == [u8(0x00), 0xff]

	mut d := decoder_new(e.data)
	assert d.get_u8() == math.min_u8
	assert d.get_u8() == math.max_u8
}

fn test_u16() {
	mut e := new()
	e.add_u16(math.min_u16)
	e.add_u16(math.max_u16)
	assert e.data == [u8(0x00), 0x00, 0xff, 0xff]

	mut d := decoder_new(e.data)
	assert d.get_u16() == math.min_u16
	assert d.get_u16() == math.max_u16
}

fn test_u32() {
	mut e := new()
	e.add_u32(math.min_u32)
	e.add_u32(math.max_u32)
	assert e.data == [u8(0x00), 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff]

	mut d := decoder_new(e.data)
	assert d.get_u32() == math.min_u32
	assert d.get_u32() == math.max_u32
}

fn test_u64() {
	mut e := new()
	e.add_u64(math.min_u64)
	e.add_u64(math.max_u64)
	assert e.data == [u8(0x00), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff,
		0xff, 0xff, 0xff, 0xff]

	mut d := decoder_new(e.data)
	assert d.get_u64() == math.min_u64
	assert d.get_u64() == math.max_u64
}

fn test_time() {
	mut e := new()
	t := time.now()
	e.add_time(t)

	mut d := decoder_new(e.data)
	assert d.get_time() == t
}

fn test_list_string() {
	list := ['a', 'bc', 'def']

	mut e := new()
	e.add_list_string(list)
	assert e.data == [u8(3), 0, 1, 0, 97, 2, 0, 98, 99, 3, 0, 100, 101, 102]

	mut d := decoder_new(e.data)
	assert d.get_list_string() == list
}

fn test_list_int() {
	list := [0x872fea95, 0, 0xfdf2e68f]

	mut e := new()
	e.add_list_int(list)
	assert e.data == [u8(3), 0, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := decoder_new(e.data)
	assert d.get_list_int() == list
}

fn test_list_u8() {
	list := [u8(153), 0, 22]

	mut e := new()
	e.add_list_u8(list)
	assert e.data == [u8(3), 0, 153, 0, 22]

	mut d := decoder_new(e.data)
	assert d.get_list_u8() == list
}

fn test_list_u16() {
	list := [u16(0x8725), 0, 0xfdff]

	mut e := new()
	e.add_list_u16(list)
	assert e.data == [u8(3), 0, 0x25, 0x87, 0, 0, 0xff, 0xfd]

	mut d := decoder_new(e.data)
	assert d.get_list_u16() == list
}

fn test_list_u32() {
	list := [u32(0x872fea95), 0, 0xfdf2e68f]

	mut e := new()
	e.add_list_u32(list)
	assert e.data == [u8(3), 0, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := decoder_new(e.data)
	assert d.get_list_u32() == list
}

fn test_map_string() {
	mp := {
		'1': 'a'
		'2': 'bc'
	}

	mut e := new()
	e.add_map_string(mp)
	assert e.data == [u8(2), 0, 1, 0, 49, 1, 0, 97, 1, 0, 50, 2, 0, 98, 99]

	mut d := decoder_new(e.data)
	assert d.get_map_string() == mp
}

fn test_map_bytes() {
	mp := {
		'1': 'a'.bytes()
		'2': 'bc'.bytes()
	}

	mut e := new()
	e.add_map_bytes(mp)
	assert e.data == [u8(2), 0, 1, 0, 49, 1, 0, 0, 0, 97, 1, 0, 50, 2, 0, 0, 0, 98, 99]

	mut d := decoder_new(e.data)
	assert d.get_map_bytes() == mp
}

struct StructType[T] {
mut:
	val T
}

fn get_empty_struct_input[T]() StructType[T] {
	return StructType[T]{}
}

fn get_struct_input[T](val T) StructType[T] {
	return StructType[T]{
		val: val
	}
}

fn encode_decode_struct[T](input StructType[T]) bool {
	data := encode(input) or {
		console.print_debug('Failed to encode, error: ${err}')
		return false
	}
	output := decode[StructType[T]](data) or {
		console.print_debug('Failed to decode, error: ${err}')
		return false
	}
	return input == output
}

fn test_struct() {
	// string
	assert encode_decode_struct(get_empty_struct_input[string]())
	assert encode_decode_struct(get_struct_input(''))
	assert encode_decode_struct(get_struct_input('a'))

	// int
	assert encode_decode_struct(get_empty_struct_input[int]())
	assert encode_decode_struct(get_struct_input(-1))

	// u8
	assert encode_decode_struct(get_empty_struct_input[u8]())
	assert encode_decode_struct(get_struct_input(u8(2)))

	// u16
	assert encode_decode_struct(get_empty_struct_input[u16]())
	assert encode_decode_struct(get_struct_input(u16(3)))

	// u32
	assert encode_decode_struct(get_empty_struct_input[u32]())
	assert encode_decode_struct(get_struct_input(u32(4)))

	// u64
	assert encode_decode_struct(get_empty_struct_input[u64]())
	assert encode_decode_struct(get_struct_input(u64(5)))

	// time.Time
	// assert encode_decode_struct[time.Time](get_empty_struct_input[time.Time]()) // get error here
	assert encode_decode_struct[time.Time](get_struct_input[time.Time](time.now()))

	// string array
	assert encode_decode_struct(get_empty_struct_input[[]string]())
	assert encode_decode_struct(get_struct_input([]string{}))
	assert encode_decode_struct(get_struct_input(['']))
	assert encode_decode_struct(get_struct_input(['a']))

	// int array
	assert encode_decode_struct(get_empty_struct_input[[]int]())
	assert encode_decode_struct(get_struct_input([]int{}))
	assert encode_decode_struct(get_struct_input([-1]))

	// u8 array
	assert encode_decode_struct(get_empty_struct_input[[]u8]())
	assert encode_decode_struct(get_struct_input([]u8{}))
	assert encode_decode_struct(get_struct_input([u8(2)]))

	// u16 array
	assert encode_decode_struct(get_empty_struct_input[[]u16]())
	assert encode_decode_struct(get_struct_input([]u16{}))
	assert encode_decode_struct(get_struct_input([u16(3)]))

	// u32 array
	assert encode_decode_struct(get_empty_struct_input[[]u32]())
	assert encode_decode_struct(get_struct_input([]u32{}))
	assert encode_decode_struct(get_struct_input([u32(4)]))

	// u64 array
	assert encode_decode_struct(get_empty_struct_input[[]u64]())
	assert encode_decode_struct(get_struct_input([]u64{}))
	assert encode_decode_struct(get_struct_input([u64(5)]))

	// string map
	assert encode_decode_struct(get_empty_struct_input[map[string]string]())
	assert encode_decode_struct(get_struct_input(map[string]string{}))
	assert encode_decode_struct(get_struct_input({
		'1': 'a'
	}))

	// bytes map
	assert encode_decode_struct(get_empty_struct_input[map[string][]u8]())
	assert encode_decode_struct(get_struct_input(map[string][]u8{}))
	assert encode_decode_struct(get_struct_input({
		'1': 'a'.bytes()
	}))

	// struct
	assert encode_decode_struct(get_empty_struct_input[StructType[int]]())
	assert encode_decode_struct(get_struct_input(StructType[int]{}))
	// assert encode_decode_struct(get_struct_input(StructType[int]{
	// 		val: int(1)
	// 	}))   // decode not implemented
}
