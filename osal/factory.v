module osal

import freeflowuniverse.crystallib.redisclient
import log

pub struct Osal {
mut:
	redis  redisclient.Redis
	logger &log.Logger
}

pub fn new(redis_address string, logger &log.Logger) !Osal {
	return Osal{
		redis: redisclient.get(redis_address)!
		logger: unsafe { logger }
	}
}
