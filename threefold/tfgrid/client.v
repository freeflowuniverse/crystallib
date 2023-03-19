module tfgrid

import freeflowuniverse.crystallib.redisclient


pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis [str: skip]
	rpc &redisclient.RedisRpc [str: skip]
}


fn new()! TFGridClient {
	mut redis := redisclient.core_get()
	mut rpc:=redis.rpc_get()
	mut cl:=TFGridClient{
		redis:&redis
		rpc:&rpc
	}
	return cl
}


