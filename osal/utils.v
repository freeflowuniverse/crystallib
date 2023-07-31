module osal

import log

pub fn get_logger() log.Logger {
	log_level := env_get_default("OSAL_LOG_LEVEL", "info")
	return log.Logger(&log.Log{
		level: match log_level.to_lower() {
			"debug" { .debug }
			"info" { .info }
			"warn" { .warn }
			"error" { .error }
			else { .info }
		}
	})
}
