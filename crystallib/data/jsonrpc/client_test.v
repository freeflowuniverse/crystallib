module jsonrpc

import log
import freeflowuniverse.crystallib.data.rpcwebsocket { new_rpcwsclient }
import net.websocket
import time

struct TestJsonRpcClient {
mut:
	transport IRpcTransportClient
}

// fn test_new() {
// 	mut s := websocket.new_server(.ip6, 8080, '')
// 	defer {
// 		unsafe {
// 			s.free()
// 		}
// 	}

// 	s.on_connect(fn (mut s websocket.ServerClient) !bool {
// 		return true
// 	})!

// 	s.on_message(fn (mut ws websocket.Client, msg &websocket.Message) ! {})
// 	s.on_close(fn (mut ws websocket.Client, code int, reason string) ! {})
// 	spawn s.listen()
// 	time.sleep(10000000)

// 	mut logger := log.Logger(&log.Log{
// 		level: .debug
// 	})

// 	client := TestJsonRpcClient{
// 		transport: new_rpcwsclient('ws://localhost:8080', &logger)!
// 	}
// }

fn test_send_json_rpc() {
	mut s := websocket.new_server(.ip6, 8081, '')
	defer {
		unsafe {
			s.free()
		}
	}

	s.on_connect(fn (mut s websocket.ServerClient) !bool {
		return true
	})!

	s.on_message(fn (mut ws websocket.Client, msg &websocket.Message) ! {
		request := jsonrpcrequest_decode[string](msg.payload.bytestr())!
		response := new_jsonrpcresponse[string](request.id, 'result')
		ws.write_string(response.to_json())!
	})
	s.on_close(fn (mut ws websocket.Client, code int, reason string) ! {})
	spawn s.listen()
	time.sleep(10000000)

	mut logger := log.Logger(&log.Log{
		level: .debug
	})

	mut transport := new_rpcwsclient('ws://localhost:8081', &logger)!
	spawn transport.run()
	mut client := TestJsonRpcClient{
		transport: transport
	}

	mut rpc_client := IJsonRpcClient(client)
	result := rpc_client.send_json_rpc[string, string]('echo', 'payload', 1000)!
	assert result == 'result'
}
