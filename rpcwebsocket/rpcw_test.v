module rpcwebsocket

import freeflowuniverse.crystallib.jsonrpc
import log
import net.websocket
import time

fn run_client(address string, logger &log.Logger, messages []int) ![]string {
	mut myclient := new_rpcwsclient(address, logger)!
	t_client := spawn myclient.run()
	mut responses := []string{}
	for message in messages {
		responses << myclient.send_json_rpc[int, string]('mymethod', message, 5000)!
	}
	myclient.client.close(0, "I'm done here")!
	t_client.wait()!
	return responses
}

fn handler(client &websocket.Client, message string) string {
	request := jsonrpc.jsonrpcrequest_decode[int](message) or { return '' }
	return jsonrpc.new_jsonrpcresponse[string](request.id, 'Response on ${request.params}').to_json()
}

fn test_client_server() {
	port := 8080
	address := 'http://127.0.0.1:${port}'
	mut logger := log.Logger(&log.Log{
		level: .info
	})
	mut myserver := new_rpcwsserver(port, handler, &logger)!
	t_server := spawn myserver.run()
	// wait till server ready
	for myserver.server.get_state() != .open {
		time.sleep(100 * time.millisecond)
	}

	messages := [1, 2, 3, 4, 5]
	responses := run_client(address, &logger, messages)!
	expected_responses := messages.map('Response on ${it}')
	assert responses == expected_responses
}
