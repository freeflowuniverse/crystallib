module encoder
import encoding.binary as bin

pub struct Decoder {
pub mut:
	version u8=1 //is important
	data []u8
}

pub fn decoder_new(data []u8) Decoder {
	mut e:=Decoder{}
	e.data = data
	// e.data = data.reverse()
	e.version = e.get_u8()
	if e.version!=1{
		panic("the version needs to be 1, incompatible serialization format.")
	}
	return e
}


//adds u16 length of string in bytes + the bytes
pub fn (mut d Decoder) get_u8() u8 {
	//remove first  byte, this corresponds to u8, so the data bytestring becomes 1 byte shorter	
	v:= d.data.first()
    d.data.delete(0)
	return v
}

//TODO: implement all other types

pub fn (mut d Decoder) get_string() string {
	//TODO
	return ""
}

pub fn (mut d Decoder) get_int() int {
	return int(d.get_u32())
}

pub fn (mut d Decoder) get_u16() u16 {
	v:=d.data[0..1]
	d.data.delete_many(0, 2)
	return bin.little_endian_u16(v)
}

pub fn (mut d Decoder) get_u32() u32 {
	v:=d.data[0..3]
	d.data.delete_many(0, 4)
	return bin.little_endian_u32(v)
}