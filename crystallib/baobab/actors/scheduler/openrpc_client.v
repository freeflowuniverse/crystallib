module scheduler

import baobab.seeds.schedule { Calendar }
import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

struct SchedulerClient {
mut:
	transport jsonrpc.IRpcTransportClient
}

@[params]
pub struct WsClientConfig {
	address string
	logger  log.Logger
}

pub fn new_ws_client(config WsClientConfig) !&SchedulerClient {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger) or {
		return error('Failed to create RPC Websocket Client
${err}')
	}
	spawn transport.run()
	c := SchedulerClient{
		transport: transport
	}
	return &c
}

pub fn (mut client SchedulerClient) new_calendar(calendar Calendar) !string {
	request := jsonrpc.new_jsonrpcrequest[Calendar]('new_calendar', calendar)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[string]).result
}

pub fn (mut client SchedulerClient) get_calendar(id string) !Calendar {
	request := jsonrpc.new_jsonrpcrequest[string]('get_calendar', id)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[Calendar](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[Calendar]).result
}

pub fn (mut client SchedulerClient) set_calendar(calendar Calendar) ! {
	request := jsonrpc.new_jsonrpcrequest[Calendar]('set_calendar', calendar)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
}

pub fn (mut client SchedulerClient) delete_calendar(id string) ! {
	request := jsonrpc.new_jsonrpcrequest[string]('delete_calendar', id)
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[string](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
}

pub fn (mut client SchedulerClient) list_calendar() !CalendarList {
	request := jsonrpc.new_jsonrpcrequest[string]('list_calendar', '')
	resp_json := client.transport.send(request.to_json(), 6000)!
	response := jsonrpc.decode_response[CalendarList](resp_json)!
	if response is jsonrpc.JsonRpcError {
		return response.error
	}
	return (response as jsonrpc.JsonRpcResponse[CalendarList]).result
}
