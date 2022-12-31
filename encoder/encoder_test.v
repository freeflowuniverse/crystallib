module encoder

fn test_string() {
	mut e := encoder.encoder_new()
	e.add_string('a')
	e.add_string('bc')
	e.add_string('def')
	assert e.data == [e.version, 1, 0, 97, 2, 0, 98, 99, 3, 0, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_string() == 'a'
	assert d.get_string() == 'bc'
	assert d.get_string() == 'def'
}

fn test_int() {
	mut e := encoder.encoder_new()
	e.add_int(0x872fea95)
	e.add_int(0)
	e.add_int(0xfdf2e68f)
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_int() == 0x872fea95
	assert d.get_int() == 0
	assert d.get_int() == 0xfdf2e68f
}

fn test_bytes() {
	sb := 'abcdef'.bytes()

	mut e := encoder.encoder_new()
	e.add_list_u8(sb)
	assert e.data == [e.version, 6, 0, 97, 98, 99, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u8() == sb
}

fn test_u8() {
	mut e := encoder.encoder_new()
	e.add_u8(153)
	e.add_u8(0)
	e.add_u8(22)
	assert e.data == [e.version, 153, 0, 22]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u8() == 153
	assert d.get_u8() == 0
	assert d.get_u8() == 22
}

fn test_u16() {
	mut e := encoder.encoder_new()
	e.add_u16(0x8725)
	e.add_u16(0)
	e.add_u16(0xfdff)
	assert e.data == [e.version, 0x25, 0x87, 0, 0, 0xff, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u16() == 0x8725
	assert d.get_u16() == 0
	assert d.get_u16() == 0xfdff
}

fn test_u32() {
	mut e := encoder.encoder_new()
	e.add_u32(0x872fea95)
	e.add_u32(0)
	e.add_u32(0xfdf2e68f)
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u32() == 0x872fea95
	assert d.get_u32() == 0
	assert d.get_u32() == 0xfdf2e68f
}

fn test_list_string() {
	list := ['a', 'bc', 'def']

	mut e := encoder.encoder_new()
	e.add_list_string(list)
	assert e.data == [e.version, 3, 0, 1, 0, 97, 2, 0, 98, 99, 3, 0, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_string() == list
}

fn test_list_int() {
	list := [0x872fea95, 0, 0xfdf2e68f]

	mut e := encoder.encoder_new()
	e.add_list_int(list)
	assert e.data == [e.version, 3, 0, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_int() == list
}

fn test_list_u8() {
	list := [u8(153), 0, 22]

	mut e := encoder.encoder_new()
	e.add_list_u8(list)
	assert e.data == [e.version, 3, 0, 153, 0, 22]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u8() == list
}

fn test_list_u16() {
	list := [u16(0x8725), 0, 0xfdff]

	mut e := encoder.encoder_new()
	e.add_list_u16(list)
	assert e.data == [e.version, 3, 0, 0x25, 0x87, 0, 0, 0xff, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u16() == list
}

fn test_list_u32() {
	list := [u32(0x872fea95), 0, 0xfdf2e68f]

	mut e := encoder.encoder_new()
	e.add_list_u32(list)
	assert e.data == [e.version, 3, 0, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u32() == list
}

fn test_map_string() {
	m := {
		'1': 'a'
		'2': 'bc'
		'3': 'def'
	}
	
	mut e := encoder.encoder_new()
	e.add_map_string(m)
	assert e.data == [e.version, 3, 0, 1, 0, 49, 1, 0, 97, 1, 0, 50, 2, 0, 98, 99, 1, 0, 51, 3, 0, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_map_string() == m
}

fn test_map_bytes() {
	m := {
		'1': 'a'.bytes()
		'2': 'bc'.bytes()
		'3': 'def'.bytes()
	}
	
	mut e := encoder.encoder_new()
	e.add_map_bytes(m)
	assert e.data == [e.version, 3, 0, 1, 0, 49, 1, 0, 0, 0, 97, 1, 0, 50, 2, 0, 0, 0, 98, 99, 1, 0, 51, 3, 0, 0, 0, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_map_bytes() == m
}