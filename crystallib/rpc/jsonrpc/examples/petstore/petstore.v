module main

import freeflowuniverse.crystallib.data.rpcwebsocket
import freeflowuniverse.crystallib.data.jsonrpc
import freeflowuniverse.crystallib.ui.console
import log
import json

@[heap]
pub struct Petstore {
	pets map[string]Pet
}

pub fn (mut handler Petstore) get_pet(name string) !Pet {
	console.print_debug('called ${name}')
	return handler.pets[name] or { return error('Pet `${name}` not found') }
}
