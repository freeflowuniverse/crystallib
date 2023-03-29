module jsonrpc

import json
import rand


const (
	jsonrpc_version = "2.0"
)

pub struct JsonRpcRequest[T]{
pub mut:
	jsonrpc string = jsonrpc_version
	method string
	params T
	id string
}

pub fn (j &JsonRpcRequest[T]) to_json() string {
	return json.encode(j)
}

pub struct JsonRpcResponse[T]{
pub mut:
	jsonrpc string = jsonrpc_version
	result T
	id string
}

pub fn (j &JsonRpcResponse[T]) to_json() string {
	return json.encode(j)
}

pub struct JsonRpcError{
pub mut:
	jsonrpc string = jsonrpc_version
	error InnerJsonRpcError [required]
	id string
}

struct InnerJsonRpcError{
pub mut:
	code int [required]
	message string [required]
	data string
}

pub fn (j &JsonRpcError) to_json() string {
	return json.encode(j)
}

pub fn new_jsonrpcrequest[T](method string, params T) JsonRpcRequest[T] {
	return JsonRpcRequest[T]{
		method: method
		params: params
		id: rand.uuid_v4()
	}
}

pub fn new_jsonrpcresponse[T](id string, result T) JsonRpcResponse[T] {
	return JsonRpcResponse[T]{
		result: result
		id: id
	}
}

pub fn new_jsonrpcerror(id string, code int, message string, data string) JsonRpcError {
	return JsonRpcError{
		error: struct {
			code: code
			message: message
			data: data
		}
		id: id
	}
}

pub fn jsonrpcrequest_decode[T](data string) !JsonRpcRequest[T] {
	return json.decode(JsonRpcRequest[T], data)!
}

pub fn jsonrpcresponse_decode[T](data string) !JsonRpcResponse[T] {
	return json.decode(JsonRpcResponse[T], data)!
}

pub fn jsonrpcerror_decode(data string) !JsonRpcError {
	return json.decode(JsonRpcError, data)!
}