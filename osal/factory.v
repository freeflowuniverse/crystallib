module osal

import freeflowuniverse.crystallib.redisclient
import log

pub struct Osal {
mut:
	redis  redisclient.Redis
	logger &log.Logger
}

[params]
pub struct OsalArgs {
pub mut:
	redis_address string = "localhost:6379"
	logger log.Logger = log.Logger(&log.Log{ level: .info})
}

pub fn new(args OsalArgs) !Osal {
	return Osal{
		redis: redisclient.get(args.redis_address)!
		logger: &args.logger
	}
}
