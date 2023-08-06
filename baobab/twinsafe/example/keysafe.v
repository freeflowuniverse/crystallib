module main

import freeflowuniverse.crystallib.baobab.twinsafe

fn do()! {

	data :="
		this is some text
		don't wanna make it too small
		lets see where this brings us
	"
	
	// TODO: create some messages and see it all works properly
	// TODO: create some twins and query them
}


fn main() {
	do() or {panic(err)}
}