module accountant

import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

const port = 3000

pub fn test_new_ws_client() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${accountant.port}')!
}

pub fn test_new_budget() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${accountant.port}')!
	client.new_budget()
}

pub fn test_get_budget() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${accountant.port}')!
	client.get_budget()
}

pub fn test_set_budget() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${accountant.port}')!
	client.set_budget()
}

pub fn test_delete_budget() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${accountant.port}')!
	client.delete_budget()
}

pub fn test_list_budget() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${accountant.port}')!
	client.list_budget()
}
