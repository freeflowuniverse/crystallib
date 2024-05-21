module scheduler

import baobab.seeds.schedule { Calendar }
import freeflowuniverse.crystallib.rpc.jsonrpc
import json
import x.json2

@[heap]
struct SchedulerHandler {
	state Scheduler
}

// handle handles an incoming JSON-RPC encoded message and returns an encoded response
pub fn (mut handler SchedulerHandler) handle(msg string) !string {
	method := jsonrpc.jsonrpcrequest_decode_method(msg)!
	match method {
		'new_calendar' {
			return jsonrpc.call[Calendar, string](msg, handler.state.new_calendar)!
		}
		'get_calendar' {
			return jsonrpc.call[string, Calendar](msg, handler.state.get_calendar)!
		}
		'set_calendar' {
			return jsonrpc.call_void[Calendar](msg, handler.state.set_calendar)!
		}
		'delete_calendar' {
			return jsonrpc.call_void[string](msg, handler.state.delete_calendar)!
		}
		'list_calendar' {
			return jsonrpc.invoke[CalendarList](msg, handler.state.list_calendar)!
		}
		else {
			return error('method ${method} not handled')
		}
	}
	return error('this should never happen')
}
