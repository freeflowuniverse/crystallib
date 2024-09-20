module log

pub fn (mut logger Logger) new_log(log Log) ! {
	sql logger.backend.db {
		insert log into Log
	}!
}

pub fn (mut logger Logger) get_logs(log Log) ![]Log {
	logs := sql logger.backend.db {
		select from Log
	}!
	return logs
}