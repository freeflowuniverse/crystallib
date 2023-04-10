module redisclient

import freeflowuniverse.crystallib.jsonrpc
import time

const (
	parse_err_code                  = -32700
	invalid_request_object_err_code = -32600
	method_not_found_err_code       = -32601
	invalid_params_err_code         = -32602
	internal_err_code               = -32603
	server_err_code                 = -32000
)

pub struct RedisRpc {
pub mut:
	key   string
	redis &Redis
}

// return a rpc mechanism
pub fn (mut r Redis) rpc_get(key string) RedisRpc {
	return RedisRpc{
		key: key
		redis: r
	}
}

pub struct Message {
pub:
	ret_queue string
	now       i64
	cmd       string
	data      string
}

pub struct Response {
pub:
	result string
	error  string
}

struct MethodNotFoundErr {
	Error
	method string
}

// send jsonrpc data to a queue and return the return queue
// params
// 	method string
// 	data T
pub fn (mut q RedisRpc) call[T](method string, data T) !string {
	json_rpc := jsonrpc.new_jsonrpcrequest[T](method, data)

	encoded := json_rpc.to_json()
	q.redis.lpush(q.key, encoded)!
	return json_rpc.id
}

// get return once result processed
pub fn (mut q RedisRpc) result[T](timeout u64, retqueue string) !T {
	queues := [retqueue]
	r := q.redis.brpop(queues, timeout) or { return error('timeout on queue: ${retqueue}') }

	// if redis brpop did not return an error,
	// the response is garuanteed to be a string array with len = 2
	result := r[1]
	if result != '' {
		error_check := jsonrpc.jsonrpcerror_decode(result) or {
			// it is not an error so decode json rpc
			jsonrpc_response := jsonrpc.jsonrpcresponse_decode[T](result)!
			return jsonrpc_response.result
		}
		return error('Error ${error_check.error.code}: ${error_check.error.message}')
	}

	return error('got empty value from redis on queue: ${retqueue}')
}

// to be used by processor, to get request and execute, this is the server side of a RPC mechanism
// 2nd argument is a function which needs to execute the job: fn (string,string) !string
pub fn (mut q RedisRpc) process[T, P](timeout u64, op fn (string, T) !P) ! {
	queues := [q.key]
	r := q.redis.brpop(queues, timeout) or { return error('timeout on queue: ${q.key}') }

	value := r[1]
	if value != '' {
		json_rpc_request := jsonrpc.jsonrpcrequest_decode[T](value) or {
			// return error with code -32700 (parse error)
			push_error(json_rpc_request.id, redisclient.parse_err_code, '${err}', '')!
			return
		}
		if !is_method_found(json_rpc_request.method) {
			// return error with code -32601 (method not found)
			push_error(json_rpc_request.id, redisclient.method_not_found_err_code, '${err}',
				'')!
			return
		}

		if !are_params_valid[T](json_rpc_request.method, json_rpc_request.params) {
			// return error with code -32700 (invalid params)
			push_error(json_rpc_request.id, redisclient.invalid_params_err_code, '${err}',
				'')!
			return
		}

		result := op(json_rpc_request.method, json_rpc_request.params) or {
			// return error with code -32000 (server error)
			push_error(json_rpc_request.id, redisclient.server_err_code, '${err}', '')!
			return
		}

		json_rpc_response := jsonrpc.new_jsonrpcresponse[P](json_rpc_request.id, result)
		encoded := json_rpc_response.to_json()
		q.redis.lpush(json_rpc_request.id, encoded)!
		return
	}

	return error('got empty value from redis on queue: ${q.key}')
}

// get without timeout, returns none if nil
pub fn (mut q RedisRpc) delete() ! {
	q.redis.del(q.key)!
}

fn (q RedisRpc) is_method_found(method string) bool {
	// TODO: check if method is registered
	return true
}

fn (q RedisRpc) are_params_valid[T](method string, params T) bool {
	// TODO: check if params are valid
	return true
}

fn (mut q RedisRpc) push_error(id string, code int, message string, data string) ! {
	json_rpc_error := jsonrpc.new_jsonrpcerror(id, code, message, data)
	encoded := json_rpc_error.to_json()
	q.redis.lpush(id, encoded)!
}
