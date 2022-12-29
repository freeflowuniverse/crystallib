module main

import freeflowuniverse.crystallib.encoder
import crypto.ed25519

struct AStruct{
	items []string
	nr int
}

fn do1() ? {
	mut b := encoder.encoder_new()
	a:=AStruct{
		items:(['a', 'b']
		nr: 10
		privkey: []u8
	}
	b.add_list_string(a.items)
	b.add_int(a.nr)
	pubkey, privkey := ed25519.generate_key()?
	b.add_bytes(privkey)

	println(b.data)
	a2:=AStruct{}
	//TODO: needs to be implemented
	a2.items = b.get_list_string()
	a2.nr = b.get_int()
	a2.privkey = b.get_bytes()

	//TODO: do an assert and copy the code to the autotests

}

fn do1() ? {

	a:=AStruct{
		items:(['a', 'b']
		nr: 10
		privkey: []u8
	}

	serialize_data:=encoder.encode(a)

	b := encoder.decode(AStruct, serialize_data) or {
	eprintln('Failed to decode, error: ${err}')
	return
}



}


fn main() {
	do1() or { panic(err) }
	do2() or { panic(err) }
}


>TODO: adjust