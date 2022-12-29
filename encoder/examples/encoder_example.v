module main

import freeflowuniverse.crystallib.resp
import crypto.ed25519

struct AStruct{
	items []string
	nr int
}

fn do() ? {
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

fn main() {
	do() or { panic(err) }
}


>TODO: adjust