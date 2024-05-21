module coordinator

import log
import net.websocket
import freeflowuniverse.crystallib.rpc.rpcwebsocket

pub fn (mut handler CoordinatorHandler) handle_ws(client &websocket.Client, message string) string {
	return handler.handle(message) or { panic(err) }
}

pub fn run_wsserver(port int) ! {
	log_ := log.Log{
		level: .debug
	}
	mut logger := log.Logger(&log_)
	mut handler := CoordinatorHandler{get(name: 'coordinator')!}
	mut server := rpcwebsocket.new_rpcwsserver(port, handler.handle_ws, logger)!
	server.run()!
}
