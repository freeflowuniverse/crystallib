module coordinator

import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

const port = 3000

pub fn test_new_ws_client() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${coordinator.port}')!
}

pub fn test_new_story() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${coordinator.port}')!
	client.new_story()
}

pub fn test_get_story() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${coordinator.port}')!
	client.get_story()
}

pub fn test_set_story() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${coordinator.port}')!
	client.set_story()
}

pub fn test_delete_story() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${coordinator.port}')!
	client.delete_story()
}

pub fn test_list_story() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${coordinator.port}')!
	client.list_story()
}
