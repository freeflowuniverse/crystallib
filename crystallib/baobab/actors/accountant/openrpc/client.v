module accountant

import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

struct Accountant {
	transport &jsonrpc.IRpcTransportClient
}

@[params]
struct WsClientConfig {
	address string
	logger  log.Logger
}

pub fn new_ws_client(config WsClientConfig) !Accountant {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return Accountant{
		transport: transport
	}
}

pub fn (client Accountant) new_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('new_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Accountant) get_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('get_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Accountant) set_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('set_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Accountant) delete_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Accountant) list_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('list_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}
