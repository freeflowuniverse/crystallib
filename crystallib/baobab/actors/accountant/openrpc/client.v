module accountant

struct accountant {
	transport &jsonrpc.IRpcTransportClient
}

@[params]
struct WsClientConfig {
	address string
	logger  log.Logger
}

//
pub fn new_ws_client(config WsClientConfig) !accountant {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return accountant{
		transport: transport
	}
}

//
pub fn (client accountant) create_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('create_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client accountant) read_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('read_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client accountant) update_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('update_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client accountant) delete_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client accountant) list_budget() {
	request := jsonrpc.new_jsonrpcrequest[string]('list_budget', '')
	_ := client.transport.send(request.to_json(), 6000)!
}
