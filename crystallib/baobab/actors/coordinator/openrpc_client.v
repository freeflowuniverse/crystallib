module coordinator

import baobab.seeds.project { Story }
import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

struct CoordinatorClient {
mut:
	transport jsonrpc.IRpcTransportClient
}

@[params]
pub struct WsClientConfig {
	address string
	logger  log.Logger
}

pub fn new_ws_client(config WsClientConfig) !&CoordinatorClient {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger) or {
		return error('Failed to create RPC Websocket Client
${err}')
	}
	spawn transport.run()
	c := CoordinatorClient{
		transport: transport
	}
	return &c
}

pub fn (mut client CoordinatorClient) new_story(story Story) !string {
	request := jsonrpc.new_jsonrpcrequest[Story]('new_story', story)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[string]).result
}

pub fn (mut client CoordinatorClient) get_story(id string) !Story {
	request := jsonrpc.new_jsonrpcrequest[string]('get_story', id)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[Story](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[Story]).result
}

pub fn (mut client CoordinatorClient) set_story(story Story) ! {
	request := jsonrpc.new_jsonrpcrequest[Story]('set_story', story)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
}

pub fn (mut client CoordinatorClient) delete_story(id string) ! {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_story', id)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
}

pub fn (mut client CoordinatorClient) list_story() !StoryList {
	request := jsonrpc.new_jsonrpcrequest[string]('list_story', '')
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[StoryList](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[StoryList]).result
}
