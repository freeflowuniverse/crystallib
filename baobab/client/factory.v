module client

import freeflowuniverse.crystallib.redisclient

pub struct Client {
pub mut:
	redis  redisclient.Redis
	twinid u32
}

// Factory method to create a client. It takes in
// the address where the redis server is running.
// Make sure to put the twinid of the system in
// the redis key client.mytwin.id.
pub fn new(redis_address string) !Client {
	mut redis := redisclient.get(redis_address)!
	mut client := Client{
		redis: redis
	}
	twinid := client.redis.get('client.mytwin.id') or { '0' }
	client.twinid = twinid.u32()
	return client
}
