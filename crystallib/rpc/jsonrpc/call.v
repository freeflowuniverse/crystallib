module jsonrpc

import x.json2

// performs jsonrpc call on provided method
pub fn call[T, D](msg string, method fn (T) !D) !string {
	request := jsonrpcrequest_decode[T](msg)!
	if result := method(request.params) {
		response := JsonRpcResponse[D]{
			id: request.id
			jsonrpc: request.jsonrpc
			result: result
		}
		return response.to_json()
	} else {
		response := new_jsonrpcerror(request.id, 0, err.msg(), '')
		return response.to_json()
	}
}

// performs jsonrpc call on provided method without parameters
pub fn invoke[T](msg string, method fn () !T) !string {
	request := jsonrpcrequest_decode[string](msg)!
	if result := method() {
		response := JsonRpcResponse[D]{
			id: request.id
			jsonrpc: request.jsonrpc
			result: result
		}
		return response.to_json()
	} else {
		response := new_jsonrpcerror(request.id, 0, err.msg(), '')
		return response.to_json()
	}
}

pub fn notify[T](msg string, method fn (T)) ! {
	request := jsonrpcrequest_decode[T](msg)!
	method(request.params)
}
