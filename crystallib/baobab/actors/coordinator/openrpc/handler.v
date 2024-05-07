module coordinator

@[heap]
struct CoordinatorHandler {
	state Coordinator
}

// handle handles an incoming JSON-RPC encoded message and returns an encoded response
pub fn (mut handler CoordinatorHandler) handle(msg string) string {
	method := jsonrpc.jsonrpcrequest_decode_method(msg)!
	match method {
		'create_story' {
			return jsonrpc.call[Story, int](msg, handler.state.create_story)!
		}
		'read_story' {
			return jsonrpc.call[string, Story](msg, handler.state.read_story)!
		}
		'update_story' {
			jsonrpc.notify[Story](msg, handler.state.update_story)!
		}
		'delete_story' {
			jsonrpc.notify[int](msg, handler.state.delete_story)!
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
