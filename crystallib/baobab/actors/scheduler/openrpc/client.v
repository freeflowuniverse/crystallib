module openrpc

import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

struct Scheduler {
mut:
	transport &jsonrpc.IRpcTransportClient
}

@[params]
struct WsClientConfig {
	address string
	logger  log.Logger
}

//
pub fn new_ws_client(config WsClientConfig) !Scheduler {
	mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return Scheduler{
		transport: transport
	}
}

//
// pub fn (mut client Scheduler) create_calendar() ! {
// 	request := jsonrpc.new_jsonrpcrequest[string]('create_calendar', '')
// 	_ := client.transport.send(request.to_json(), 6000)!
// }

// //
// pub fn (mut client Scheduler) read_calendar() ! {
// 	request := jsonrpc.new_jsonrpcrequest[string]('read_calendar', '')
// 	_ := client.transport.send(request.to_json(), 6000)!
// }

// //
// pub fn (mut client Scheduler) update_calendar() ! {
// 	request := jsonrpc.new_jsonrpcrequest[string]('update_calendar', '')
// 	_ := client.transport.send(request.to_json(), 6000)!
// }

// //
// pub fn (mut client Scheduler) delete_calendar() ! {
// 	request := jsonrpc.new_jsonrpcrequest[string]('delete_calendar', '')
// 	_ := client.transport.send(request.to_json(), 6000)!
// }

// //
// pub fn (mut client Scheduler) list_calendar() ! {
// 	request := jsonrpc.new_jsonrpcrequest[string]('list_calendar', '')
// 	_ := client.transport.send(request.to_json(), 6000)!
// }
