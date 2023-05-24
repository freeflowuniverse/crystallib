module jsonrpc

import json
import x.json2
import rand

const (
	jsonrpc_version = '2.0'
)

pub struct JsonRpcRequest[T] {
pub mut:
	jsonrpc string [required]
	method  string [required]
	params  T      [required]
	id      string [required]
}

pub fn (j &JsonRpcRequest[T]) to_json() string {
	return json.encode(j)
}

pub struct JsonRpcResponse[D] {
pub mut:
	jsonrpc string [required]
	result  D
	id      string [required]
}

pub fn (j &JsonRpcResponse[D]) to_json() string {
	// return json.encode(j)
	return ''
}

pub struct JsonRpcError {
pub mut:
	jsonrpc string            [required]
	error   InnerJsonRpcError [required]
	id      string            [required]
}

struct InnerJsonRpcError {
pub mut:
	code    int    [required]
	message string [required]
	data    string
}

pub fn (j &JsonRpcError) to_json() string {
	return json.encode(j)
}

pub fn new_jsonrpcrequest[T](method string, params T) JsonRpcRequest[T] {
	return JsonRpcRequest[T]{
		jsonrpc: jsonrpc.jsonrpc_version
		method: method
		params: params
		id: rand.uuid_v4()
	}
}

pub fn new_jsonrpcresponse[T](id string, result T) JsonRpcResponse[T] {
	return JsonRpcResponse[T]{
		jsonrpc: jsonrpc.jsonrpc_version
		result: result
		id: id
	}
}

pub fn new_jsonrpcerror(id string, code int, message string, data string) JsonRpcError {
	return JsonRpcError{
		jsonrpc: jsonrpc.jsonrpc_version
		error: InnerJsonRpcError{
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

pub fn jsonrpcrequest_decode_method(data string) !string {
	raw := json2.raw_decode(data)!
	decoded_map := raw.as_map()
	method := decoded_map['method']
	if method is string {
		return method as string
	} else {
		return error('Expected method field to be string.')
	}
}

pub fn jsonrpcresponse_decode[D](data string) !JsonRpcResponse[D] {
	return json.decode(JsonRpcResponse[D], data)!
}

pub fn jsonrpcerror_decode(data string) !JsonRpcError {
	return json.decode(JsonRpcError, data)!
}
