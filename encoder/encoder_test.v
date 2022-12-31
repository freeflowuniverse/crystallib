module encoder

fn test_string() {
	mut e := encoder.encoder_new()
	e.add_string('a')
	assert e.data == [e.version, 1, 0, 97]
	e.add_string('bc')
	assert e.data == [e.version, 1, 0, 97, 2, 0, 98, 99]
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
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87]
	e.add_int(0)
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0]
	e.add_int(0xfdf2e68f)
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_int() == 0x872fea95
	assert d.get_int() == 0
	assert d.get_int() == 0xfdf2e68f
}

fn test_u8() {
	mut b := encoder.encoder_new()
	b.add_u8(153)
	assert b.data == [b.version, 153]
	b.add_u8(0)
	assert b.data == [b.version, 153, 0]
	b.add_u8(22)
	assert b.data == [b.version, 153, 0, 22]
}

fn test_u16() {
	mut e := encoder.encoder_new()
	e.add_u16(0x8725)
	assert e.data == [e.version, 0x25, 0x87]
	e.add_u16(0)
	assert e.data == [e.version, 0x25, 0x87, 0, 0]
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
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87]
	e.add_u32(0)
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0]
	e.add_u32(0xfdf2e68f)
	assert e.data == [e.version, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u32() == 0x872fea95
	assert d.get_u32() == 0
	assert d.get_u32() == 0xfdf2e68f
}