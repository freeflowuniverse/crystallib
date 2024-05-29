module mnemonic
import freeflowuniverse.crystallib.ui.console

#include "@VMODROOT/vnemonic.h"

#flag @VMODROOT/vnemonic.o

fn C.mnemonic_from_bytes_en(bytes &u8, len usize) &char

fn C.mnemonic_to_bytes_en(mnemonic &i8, bytes_out &u8, len usize, written &usize) int

pub fn parse(mnemonic string) []u8 {
	buffer := []u8{len: 128}
	written := usize(0)

	C.mnemonic_to_bytes_en(mnemonic.str, buffer.data, 128, &written)
	mut target := []u8{len: int(written)}
	copy(mut target, buffer)

	return target
}

pub fn dumps(buffer []u8) string {
	str := C.mnemonic_from_bytes_en(buffer.data, buffer.len)
	clean := unsafe { cstring_to_vstring(str) }
	return clean
}

fn test() {
	source := 'turtle soda patrol vacuum turn fault bracket border angry rookie okay anger'
	data := parse(source)
	console.print_debug(data)

	value := dumps(data)
	console.print_debug(value)
}
