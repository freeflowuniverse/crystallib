// module main

// import freeflowuniverse.crystallib.data.rpcwebsocket
// import freeflowuniverse.crystallib.data.jsonrpc
// import log
// import json

// @[heap]
// pub struct PetstoreJsonRpcHandler {
// mut:
// 	pets map[string]Pet
// 	incoming chan string
// 	outgoing chan string
// }

// pub fn (mut handler PetstoreJsonRpcHandler) get_pet(name string) !Pet {
// 	println('called ${name}')
// 	return handler.pets[name]
// }

// pub fn (mut handler PetstoreJsonRpcHandler) run() ! {
// 	for !handler.incoming.closed {
// 		msg := <- handler.incoming
// 		method := jsonrpc.jsonrpcrequest_decode_method(msg)!
// 		mut response := ''
// 		match method {
// 			'get_pet' {
// 				response = json_rpc_call[string, Pet](msg, handler.get_pet)!
// 			}
// 			else{}
// 		}
// 		handler.outgoing <- response
// 	}
// 	// return handler.pets[name]
// }

// fn json_rpc_call[T, D](msg string, method fn(T)!D) !string {
// 	request := jsonrpc.jsonrpcrequest_decode[T](msg)!
// 	result := method(request.params)!
// 	response := jsonrpc.JsonRpcResponse[D]{
// 		id: request.id,
// 		jsonrpc: request.jsonrpc
// 		result: result
// 	}
// 	return response.to_json()
// }

// @[params]
// pub struct HandlerConfig {
// 	channel chan string
// }

// // rpcwebsocket.RpcWsClient
// pub fn new_petstore_json_rpc_handler(config HandlerConfig) !PetstoreJsonRpcHandler {
// 	return PetstoreJsonRpcHandler {
// 		incoming: config.channel
// 	}
// }

// // pub fn main() {
// // 	mut logger := log.Logger(&log.Log{level: .debug})
// // 	mut client := new_petstore_json_rpc_ws_client(
// // 		address: 'ws://127.0.0.1:8080'
// // 		logger: logger
// // 	)!
// // 	pets := client.get_pet('test_pet')!
// // }
// // pub fn new_petstore_json_rpc_rest_client(config ClientConfig) PetstoreJsonRpcClient {
// // 	return PetStoreJsonRpcClient {
// // 		transport: rpcwebsocket.new_rpcwsclient(args.address, args.logger)!
// // 	}
// // }