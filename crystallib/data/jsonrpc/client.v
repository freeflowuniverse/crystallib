module jsonrpc

import log
import freeflowuniverse.crystallib.ui.console

pub interface IRpcTransportClient {
mut:
	send(string, int) !string
}

// JSON-RPC WebSoocket Server
pub interface IJsonRpcClient {
mut:
	transport IRpcTransportClient
}

pub fn (mut client IJsonRpcClient) send_json_rpc[T, D](method string, data T, timeout int) !D {
	json_rpc_request := new_jsonrpcrequest[T](method, data)
	response := client.transport.send(json_rpc_request.to_json(), timeout)!
	error_check := jsonrpcerror_decode(response) or {
		jsonrpc_response := jsonrpcresponse_decode[D](response) or {
			return error('Unable to decode ${response}')
		}
		if jsonrpc_response.id != json_rpc_request.id {
			return error('Received response with different id ${response}')
		}
		return jsonrpc_response.result
	}
	return error('Error ${error_check.error.code}: ${error_check.error.message}')
}

// pub fn (mut client IJsonRpcClient) run() ! {
// 	client.transport.run()!
// }

// [params]
// pub struct ExecuteRpcParams {
// 	rpc_id   string
// 	rpc_json string
// 	timeout  time.Duration
// }

// pub fn (mut client JsonRpcWsClient) execute_rpc(params ExecuteRpcParams) !string {
// 	client.logger.debug('client-> executing rpc')
// 	client.send_rpc_request(params.rpc_json)!
// 	return client.get_rpc_response(params.rpc_id, params.timeout)!
// }

// fn (mut client JsonRpcWsClient) send_rpc_request(rpc_json string) ! {
// 	client.logger.debug('client-> sending rpc request')
// 	client.write_string(rpc_json) or {
// 		client.logger.error('${err}')
// 		return err
// 	}
// }

// fn (mut client JsonRpcWsClient) get_rpc_response(rpc_id string, timeout time.Duration) !string {
// 	key := 'rpc.return.${rpc_id}'
// 	response_lst := client.redis.brpop([key], timeout)! // will block and wait
// 	return response_lst[0]
// }

// pub fn (mut client JsonRpcWsClient) run() {
// 	defer {
// 		unsafe {
// 			client.free()
// 		}
// 	}

// 	client.on_open_ref(handle_open, &client)
// 	client.on_error_ref(fn (mut ws websocket.Client, err string, mut client JsonRpcWsClient) ! {
// 		client.logger.error('ws.on_error error: ${err}')
// 	}, &client)
// 	client.on_close_ref(fn (mut ws websocket.Client, code int, reason string, mut client JsonRpcWsClient) ! {
// 		client.logger.debug('WS Client: connection closed.')
// 	}, &client)
// client.on_message_ref(fn (mut ws websocket.Client, msg &websocket.Message, mut client JsonRpcWsClient) ! {
// 	client.handle_message(msg) or { panic(err) }
// }, &client)
// 	client.connect() or {
// 		client.logger.error('ws.connect err: ${err}')
// 		panic(err)
// 	}
// 	client.logger.debug('ws.connect succeeded')

// 	client.listen() or {
// 		client.logger.error('ws.listen err: ${err}')
// 		panic(err)
// 	}

// 	// client.close(100, 'normal') or {
// 	// 	client.logger.error('send_rpc, close err: ${err}')
// 	// 	panic(err)
// 	// }

// 	client.logger.debug('ws.listen finished')
// }

// fn handle_open(mut ws websocket.Client, mut client JsonRpcWsClient) ! {
// 	client.logger.debug('ws.on_open')
// }

// fn (mut client JsonRpcWsClient) handle_message(msg &websocket.Message) ! {
// 	client.logger.debug('Handling message')
// 	if msg.payload.len > 0 {
// 		data := msg.payload.bytestr()
// 		rpc_id := jsonrpcrequest_decode_id(data)!
// 		client.logger.debug('Handling response to RPC ${rpc_id}')
// 		mut q_return := client.redis.queue_get('jobs.return.${rpc_id}')
// 		q_return.add(data)!
// 	}
// }

// pub fn start_client(config ClientConfig) !&JsonRpcWsClient {
// 	mut ws := websocket.new_client('ws://localhost:8080')!

// 	// mut ws := websocket.new_client('wss://echo.websocket.org:443')?
// 	// use on_open_ref if you want to send any reference object
// 	ws.on_open(fn (mut ws websocket.Client) ! {
// 		console.print_debug(term.green('ws.on_open websocket connected to the server and ready to send messages...'))
// 	})
// 	// use on_error_ref if you want to send any reference object
// 	ws.on_error(fn (mut ws websocket.Client, err string) ! {
// 		console.print_debug(term.red('ws.on_error error: ${err}'))
// 	})
// 	// use on_close_ref if you want to send any reference object
// 	ws.on_close(fn (mut ws websocket.Client, code int, reason string) ! {
// 		console.print_debug(term.green('ws.on_close the connection to the server successfully closed'))
// 	})

// 	ws.connect() or {
// 		eprintln(term.red('ws.connect error: ${err}'))
// 		return err
// 	}
// 	mut redis := redisclient.get(config.redis_address)!
// 	ws.logger = config.logger
// 	client := JsonRpcWsClient{
// 		Client: ws
// 		redis: redis
// 	}
// 	// on new messages from other clients, display them in blue text
// 	ws.on_message_ref(fn (mut ws websocket.Client, msg &websocket.Message, mut client JsonRpcWsClient) ! {
// 		client.handle_message(msg) or { panic(err) }
// 	}, &ws)

// 	spawn ws.listen() // or { console.print_debug(term.red('error on listen $err')) }

// 	return &client
// }

@[params]
pub struct ClientConfig {
	address string // address of ws server
	logger  &log.Logger
}

// pub fn new_client(config ClientConfig) !JsonRpcWsClient {
// 	mut client := JsonRpcWsClient{
// 		Client: new_rpcwsclient(config.address, config.logger)
// 	}

// 	return client
// }
