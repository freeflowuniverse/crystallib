module main

import freeflowuniverse.crystallib.keysafe


fn do() ! {
	
	mut ks:=keysafe.keysafe_get("~/.digitaltwin","1234")!
	ks.generate_multiple(2)!
	println(ks)

	//TODO: now do further tests to load/dump with the secret

	

}

fn main() {
	do() or { panic(err) }
}
