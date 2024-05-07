module openrpc

import freeflowuniverse.crystallib.baobab.seeds.schedule {Calendar}
import freeflowuniverse.crystallib.baobab.actors.scheduler
import freeflowuniverse.crystallib.rpc.jsonrpc

@[heap]
struct SchedulerHandler {
	state scheduler.Scheduler
}

// handle handles an incoming JSON-RPC encoded message and returns an encoded response
pub fn (mut handler SchedulerHandler) handle(msg string) !string {
	method := jsonrpc.jsonrpcrequest_decode_method(msg)!
	match method {
		// 'create_calendar' {
		// 	return jsonrpc.call[Calendar, int](msg, handler.state.create_calendar)!
		// }
		// 'read_calendar' {
		// 	return jsonrpc.call[string, Calendar](msg, handler.state.read_calendar)!
		// }
		// 'update_calendar' {
		// 	jsonrpc.notify[Calendar](msg, handler.state.update_calendar)!
		// }
		// 'delete_calendar' {
		// 	jsonrpc.notify[int](msg, handler.state.delete_calendar)!
		// }
		'list_calendar' {
			return jsonrpc.invoke[[]Calendar](msg, handler.state.list_calendar)!
		}
		else {
			return error('method ${method} not handled')
		}
	}
	return error('this should never happen')
}
