module petstore_client

import freeflowuniverse.crystallib.jsonrpc {JsonRpcRequest}
import net.websocket

struct Client {
	mut:
	ws_client &websocket.Client
}

pub fn new() Client {
	address := 'localhost:8000'
	ws_client := websocket.new_client(address)!
}

fn (mut client Client) send_rpc(rpc JsonRpcRequest) ! {
	client.ws_client.write_string(rpc.to_json())
}

