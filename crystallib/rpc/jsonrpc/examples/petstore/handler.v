module main

import freeflowuniverse.crystallib.data.rpcwebsocket
import freeflowuniverse.crystallib.data.jsonrpc
import log
import jsonß

@[heap]
pub struct PetstoreJsonRpcHandler {
mut:
	petstore Petstore
}

pub fn (mut handler PetstoreJsonRpcHandler) handle(msg string) !string {
	method := jsonrpc.jsonrpcrequest_decode_method(msg)!
	match method {
		'get_pet' {
			return jsonrpc.call[string, Pet](msg, handler.petstore.get_pet)!
		}
		else{
			return error('method ${method} not handled')
		}
	}
	return error('this should never happen')
}
