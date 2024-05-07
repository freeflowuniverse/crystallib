module coordinator

struct coordinator {
	transport &jsonrpc.IRpcTransportClient
}

@[params]
struct WsClientConfig {
	address string
	logger  log.Logger
}

//
pub fn new_ws_client(config WsClientConfig) !coordinator {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return coordinator{
		transport: transport
	}
}

//
pub fn (client coordinator) create_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('create_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client coordinator) read_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('read_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client coordinator) update_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('update_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client coordinator) delete_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}

//
pub fn (client coordinator) list_story() {
	request := jsonrpc.new_jsonrpcrequest[string]('list_story', '')
	_ := client.transport.send(request.to_json(), 6000)!
}
