module petstore_client

import freeflowuniverse.crystallib.data.jsonrpc { JsonRpcRequest }
import net.websocket

struct Client {
mut:
	ws_client &websocket.Client
}

pub fn new() !Client {
	address := 'localhost:8000'
	ws_client := websocket.new_client(address)!
	return Client{ws_client}
}

fn (mut client Client) send_rpc[T](rpc JsonRpcRequest[T]) ! {
	client.ws_client.write_string(rpc.to_json())
}
