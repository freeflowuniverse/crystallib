module redisclient

import freeflowuniverse.crystallib.jsonrpc

import time

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
	start := u64(time.now().unix_time_milli())
	for {
		r := q.redis.rpop(retqueue) or { '' } // TODO: should be blocking since certain timeout
		if r != '' {
			error_check := jsonrpc.jsonrpcerror_decode(r) or {
				// it is not an error so decode json rpc
				jsonrpc_response := jsonrpc.jsonrpcresponse_decode[T](r)!
				return jsonrpc_response.result
			}
			return error("Error ${error_check.error.code}: ${error_check.error.message}")
		}

		if u64(time.now().unix_time_milli()) > (start + timeout) {
			break
		}
		time.sleep(time.millisecond)
	}
	return error('timeout on returnqueue: ${retqueue}')
}

// to be used by processor, to get request and execute, this is the server side of a RPC mechanism
// 2nd argument is a function which needs to execute the job: fn (string,string) !string
pub fn (mut q RedisRpc) process[T,P](timeout u64, op fn (string, T) !P) ! {
	start := u64(time.now().unix_time_milli())
	for {
		r := q.redis.rpop(q.key) or { '' } // TODO: should be blocking since certain timeout
		if r != '' {
			json_rpc_request := jsonrpc.jsonrpcrequest_decode[T](r)!
			result := op(json_rpc_request.method, json_rpc_request.params) or {
				// todo error code
				json_rpc_error := jsonrpc.new_jsonrpcerror(json_rpc_request.id, 11, "$err", "")
				encoded := json_rpc_error.to_json()
				q.redis.lpush(json_rpc_request.id, encoded)!
				return
			}
			json_rpc_response := jsonrpc.new_jsonrpcresponse[P](json_rpc_request.id, result)
			encoded := json_rpc_response.to_json()
			q.redis.lpush(json_rpc_request.id, encoded)!
			return
		}
		if u64(time.now().unix_time_milli()) > (start + timeout) {
			break
		}
		time.sleep(time.microsecond)
	}
	return error('timeout for waiting for cmd on ${q.key}')
}

// get without timeout, returns none if nil
pub fn (mut q RedisRpc) delete() ! {
	q.redis.del(q.key)!
}
