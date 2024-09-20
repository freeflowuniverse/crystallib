module log

pub struct Logger {
pub mut:
	backend DBBackend
}

@[params]
pub struct LoggerConfig {
pub:
	backend ?DBBackend
}

pub fn new(config LoggerConfig) !Logger {
	return Logger{
		backend: config.backend or { new_backend()! }
	}
}
