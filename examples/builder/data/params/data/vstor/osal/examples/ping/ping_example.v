module main

import freeflowuniverse.crystallib.osal { ping }

fn do() ! {
	assert ping(address: '338.8.8.8') == .unknownhost
	assert ping(address: '8.8.8.8') == .ok
	assert ping(address: '18.8.8.8') == .timeout
}

fn main() {
	do() or { panic(err) }
}
