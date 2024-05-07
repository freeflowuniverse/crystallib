module main

import freeflowuniverse.crystallib.data.rpcwebsocket
import freeflowuniverse.crystallib.data.jsonrpc
import log
import json

pub struct PetstoreJsonRpcClient {
mut:
	transport &jsonrpc.IRpcTransportClient
}

pub struct Pet{}

pub fn (mut client PetstoreJsonRpcClient) get_pet(name string) !Pet {
	request := jsonrpc.new_jsonrpcrequest[string]('get_pet', name)
	response := client.transport.send(request.to_json(), 6000)!
	return json.decode(Pet, response)!
}

@[params]
pub struct ClientConfig {
	address string
	logger log.Logger
}

// rpcwebsocket.RpcWsClient
pub fn new_petstore_json_rpc_ws_client(config ClientConfig) !PetstoreJsonRpcClient {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return PetstoreJsonRpcClient {
		transport: transport
	}
}