module coordinator

@[heap]
struct CoordinatorHandler {
	state Coordinator
}

// handle handles an incoming JSON-RPC encoded message and returns an encoded response
pub fn (mut handler CoordinatorHandler) handle(msg string) string {
	method := jsonrpc.jsonrpcrequest_decode_method(msg)!
	match method {
		'new_story' {
			return jsonrpc.call[Story, string](msg, handler.state.new_story)!
		}
		'get_story' {
			return jsonrpc.call[string, Story](msg, handler.state.get_story)!
		}
		'set_story' {
			jsonrpc.notify[Story](msg, handler.state.set_story)!
		}
		'delete_story' {
			jsonrpc.notify[string](msg, handler.state.delete_story)!
		}
		'list_story' {
			return jsonrpc.invoke[[]Story](msg, handler.state.list_story)!
		}
		else {
			return error('method ${method} not handled')
		}
	}
	return error('this should never happen')
}
