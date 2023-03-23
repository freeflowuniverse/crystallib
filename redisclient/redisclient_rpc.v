module redisclient

import rand
import time
import json

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

pub struct RPCArgs {
pub:
	cmd     string [required]
	data    string [required]
	timeout u64  = 60000 // 60 sec
	wait    bool = true
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

// send data to a queue and wait till return comes back
// timeout in milliseconds
// params
// 	cmd string [required]
// 	data string [required]
// 	timeout u64=60000  //60 sec
// 	wait bool=true
pub fn (mut q RedisRpc) call(args RPCArgs) !Response {
	// on redis queue we put: ```$returnqueue\n$epochtime\n$cmd\$data``` data typically is in json
	retqueue := rand.uuid_v4()
	now := time.now().unix_time()
	// data2 := '${retqueue}\n${now}\n${args.cmd}\n${args.data}'
	message := Message{
		ret_queue: retqueue
		now: now
		cmd: args.cmd
		data: args.data
	}
	encoded := json.encode(message)
	q.redis.lpush(q.key, encoded)!

	if args.wait {
		return q.result(args.timeout, retqueue)!
	}
	return Response{}
}

// get return once reuls processed
pub fn (mut q RedisRpc) result(timeout u64, retqueue string) !Response {
	start := u64(time.now().unix_time_milli())
	for {
		r := q.redis.rpop(retqueue) or { '' } // TODO: should be blocking since certain timeout
		if r != '' {
			return json.decode(Response, r)
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
pub fn (mut q RedisRpc) process(timeout u64, op fn (string, string) !string) !string {
	start := u64(time.now().unix_time_milli())
	for {
		r := q.redis.rpop(q.key) or { '' } // TODO: should be blocking since certain timeout
		if r != '' {
			parts := r.split_nth('\n', 4)
			if parts.len < 4 {
				return error('error on ${q.key} for return ${r}, should be 4 lines at least')
			}
			returnqueue := parts[0]
			// epochtime:=parts[1].u64() //we don't do anything with it now
			cmd := parts[2]
			data := parts[3]
			datareturn := op(cmd, data)!
			q.redis.lpush(returnqueue, datareturn)!
			return returnqueue
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
