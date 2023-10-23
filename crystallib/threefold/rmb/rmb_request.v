module rmb

import encoding.base64
import time
import json

// cmd is e.g.
pub fn (mut z RMBClient) rmb_request(cmd string, dst u32, payload string) !RmbResponse {
	msg := RmbMessage{
		ver: 1
		cmd: cmd
		exp: 5
		dat: base64.encode_str(payload)
		dst: [dst]
		ret: rand.uuid_v4()
		now: u64(time.now().unix_time())
	}
	request := json.encode_pretty(msg)
	z.redis.lpush('msgbus.system.local', request)!
	response_json := z.redis.blpop(msg.ret, 5)!
	response := json.decode(RmbResponse, response_json[1])!
	return response
}
