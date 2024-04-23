module jsonrpc

import x.json2

// performs jsonrpc call on provided method
pub fn call[T, D](msg string, method fn(T)!D) !string {
	request := jsonrpc.jsonrpcrequest_decode[T](msg)!
	if result := method(request.params) {
		response := jsonrpc.JsonRpcResponse[D]{
			id: request.id,
			jsonrpc: request.jsonrpc
			result: result
		}
		return response.to_json()
	} else {
		response := jsonrpc.new_jsonrpcerror(request.id, 0, err.msg(), '')
		return response.to_json()
	}
}

// performs jsonrpc call on provided method without parameters
pub fn invoke[T](msg string, method fn()!T) !string {
	request := jsonrpc.jsonrpcrequest_decode[string](msg)!
	if result := method() {
		response := jsonrpc.JsonRpcResponse[D]{
			id: request.id,
			jsonrpc: request.jsonrpc
			result: result
		}
		return response.to_json()
	} else {
		response := jsonrpc.new_jsonrpcerror(request.id, 0, err.msg(), '')
		return response.to_json()
	}
}

pub fn notify[T](msg string, method fn(T)) ! {
	request := jsonrpc.jsonrpcrequest_decode[T](msg)!
	method(request.params)
}