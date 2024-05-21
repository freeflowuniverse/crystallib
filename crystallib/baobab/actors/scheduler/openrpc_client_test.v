module scheduler

import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.rpc.rpcwebsocket
import log

const port = 3000

pub fn test_new_ws_client() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${scheduler.port}')!
}

pub fn test_new_calendar() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${scheduler.port}')!
	client.new_calendar()
}

pub fn test_get_calendar() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${scheduler.port}')!
	client.get_calendar()
}

pub fn test_set_calendar() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${scheduler.port}')!
	client.set_calendar()
}

pub fn test_delete_calendar() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${scheduler.port}')!
	client.delete_calendar()
}

pub fn test_list_calendar() ! {
	client := new_ws_client(address: 'ws://127.0.0.1:${scheduler.port}')!
	client.list_calendar()
}
