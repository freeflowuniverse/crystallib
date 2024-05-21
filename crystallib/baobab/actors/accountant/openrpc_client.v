module accountant

import baobab.seeds.finance { Budget }
import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

struct AccountantClient {
mut:
	transport jsonrpc.IRpcTransportClient
}

@[params]
pub struct WsClientConfig {
	address string
	logger  log.Logger
}

pub fn new_ws_client(config WsClientConfig) !&AccountantClient {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger) or {
		return error('Failed to create RPC Websocket Client
${err}')
	}
	spawn transport.run()
	c := AccountantClient{
		transport: transport
	}
	return &c
}

pub fn (mut client AccountantClient) new_budget(budget Budget) !string {
	request := jsonrpc.new_jsonrpcrequest[Budget]('new_budget', budget)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[string]).result
}

pub fn (mut client AccountantClient) get_budget(id string) !Budget {
	request := jsonrpc.new_jsonrpcrequest[string]('get_budget', id)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[Budget](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[Budget]).result
}

pub fn (mut client AccountantClient) set_budget(budget Budget) ! {
	request := jsonrpc.new_jsonrpcrequest[Budget]('set_budget', budget)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
}

pub fn (mut client AccountantClient) delete_budget(id string) ! {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_budget', id)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
}

pub fn (mut client AccountantClient) list_budget() !BudgetList {
	request := jsonrpc.new_jsonrpcrequest[string]('list_budget', '')
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[BudgetList](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[BudgetList]).result
}
