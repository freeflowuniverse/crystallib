module osal

import freeflowuniverse.crystallib.redisclient
import log

// Returns a logger object and allows you to specify via environment argument OSAL_LOG_LEVEL the debug level
pub fn get_logger() log.Logger {
	log_level := env_get_default('OSAL_LOG_LEVEL', 'info')
	return log.Logger(&log.Log{
		level: match log_level.to_lower() {
			'debug' { .debug }
			'info' { .info }
			'warn' { .warn }
			'error' { .error }
			else { .info }
		}
	})
}

// Returns a redis client object and allows you to specify via environment argument OSAL_REDIS_ADDRESS on which address to connect to
pub fn get_redis() redisclient.Redis {
	redis_address := env_get('OSAL_REDIS_ADDRESS') or {
		return redisclient.core_get() or { panic('OSAL has hard dependency to redis!') }
	}
	return redisclient.get(redis_address) or { panic('Osal has hard dependency to redis!') }
}
