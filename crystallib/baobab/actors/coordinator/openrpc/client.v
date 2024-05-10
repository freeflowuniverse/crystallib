module coordinator

import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

struct Coordinator {
	transport &jsonrpc.IRpcTransportClient
}

@[params]
struct WsClientConfig {
	address string
	logger  log.Logger
}

pub fn new_ws_client(config WsClientConfig) !Coordinator {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return Coordinator{
		transport: transport
	}
}

pub fn (client Coordinator) new_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('new_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Coordinator) get_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('get_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Coordinator) set_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('set_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Coordinator) delete_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

pub fn (client Coordinator) list_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('list_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}
