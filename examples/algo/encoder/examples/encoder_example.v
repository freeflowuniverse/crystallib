module main

import freeflowuniverse.crystallib.algo.encoder
import crypto.ed25519

struct AStruct {
mut:
	items   []string
	nr      int
	privkey []u8
}

fn do1() ! {
	_, privkey := ed25519.generate_key()!
	a := AStruct{
		items: ['a', 'b']
		nr: 10
		// privkey: []u8{len: 5, init: u8(0xf8)}
		privkey: privkey
	}

	// do encoding
	mut e := encoder.new()
	e.add_list_string(a.items)
	e.add_int(a.nr)
	e.add_bytes(privkey)

	println(e.data)

	// do decoding
	mut d := encoder.decoder_new(e.data)
	mut aa := AStruct{}
	aa.items = d.get_list_string()
	aa.nr = d.get_int()
	aa.privkey = d.get_bytes()

	assert a == aa
}

fn do2() ! {
	a := AStruct{
		items: ['a', 'b']
		nr: 10
		privkey: []u8{len: 5, init: u8(0xf8)}
	}

	serialize_data := encoder.encode(a)!

	r := encoder.decode[AStruct](serialize_data) or {
		eprintln('Failed to decode, error: ${err}')
		return
	}

	println(r)
}

fn main() {
	do1() or { panic(err) }
	do2() or { panic(err) }
}

// TODO: adjust
