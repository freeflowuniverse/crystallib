module resp


pub struct Decoder {
pub mut:
	version: u8=1 //is important
	data []u8
}

pub fn decoder_new(data []u8) Decoder {
	mut e:=Decoder{}
	e.data = data
	e.version = e.get_u8()
	if e.version!=1{
		panic("the version needs to be 1, incompatible serialization format.")
	}
}


//adds u16 length of string in bytes + the bytes
pub fn (mut b Encoder) get_u8() u8 {
	//remove first  byte, this corresponds to u8, so the data bytestring becomes 1 byte shorter	
}

//TODO: implement
