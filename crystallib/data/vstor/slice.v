module vstor

import hash.crc32

// this file does only deal with encoding/decoding of a slice, does not communicate to ZDB

// the base object which is encoded and stored on set of ZDB
// is the data part, part of a file
pub struct Slice {
pub mut:
	data   [][]u8
	parity u8 // nr of parity parts
	crc32  []u32
}

// verify that the dataobject has properly constructuted
// if crc set, then will recalculate crc to verify
pub fn (mut zo Slice) check(crc bool) ! {
	if !(zo.data.len + parity.len == zo.crc32.len) {
		return error('total length of parts need to be crc')
	}

	if crc {
		mut crc_check := []u32{}
		for d in zo.data {
			crc_check << crc.sum(d)
		}
		if zo.crc32 != zo.crc_check {
			return error('crc32 check failed')
		}
	}
}

// encode data to ZStor Objecta
// parts is the relevant parts of data e.g. 16
// parity is the overhead e.g. 4
pub fn slice_new(data []u8, parts u8, parity u8) !Slice {
	// cut into right parts
	// do the encoding

	// todo:
}

// encode the object with jerasure2 (through C binding)
// make sure crc32 also done
fn (mut zo Slice) encode() ! {
	// todo:
}

// fetch the object from ZDB's
// decode the data back to binary stream
pub fn slice_decode(zo Slice) ![]u8 {
	return zo.decode()!
}

// encode the object with jerasure2 (through C binding)
// make sure crc32 also done
fn (mut zo Slice) decode() ![]u8 {
	// TODO
	return []u8{}
}
