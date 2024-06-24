module main

import freeflowuniverse.crystallib.data.rpcwebsocket
import freeflowuniverse.crystallib.data.jsonrpc
import log
import json

@[heap]
pub struct Petstore {
	pets map[string]Pet
}

pub fn (mut handler Petstore) get_pet(name string) !Pet {
	println('called ${name}')
	return handler.pets[name] or { return error('Pet `${name}` not found') }
}
