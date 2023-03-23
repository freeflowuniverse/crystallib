module tfgrid

import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.process

pub struct Deployer {}

pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis    [str: skip]
	rpc   &redisclient.RedisRpc [str: skip]
}

fn new() !TFGridClient {
	mut redis := redisclient.core_get()
	mut rpc := redis.rpc_get('tfgrid.client')
	mut cl := TFGridClient{
		redis: &redis
		rpc: &rpc
	}
	//TODO: this is not ok, not the right way how to do this, this means there can be multiple of these running
	// process.execute_job(cmd: 'sh -c "${grid_client_path} server"')!

	return cl
}
