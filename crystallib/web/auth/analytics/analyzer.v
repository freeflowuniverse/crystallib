module analytics

import time

pub struct Log {
	timestamp time.Time
	event     Event
pub mut:
	subject string // an ID identifying the subject
	object  string // an ID identifying the object
	message string // a custom message that can be attached to a log
}

// log_request logs http requests
pub fn (mut a Analyzer) log(log Log) Log {
	return a.backend.create_log(Log{
		...log
		timestamp: time.now()
	})
}

// log_request logs http requests
pub fn (mut a Analyzer) log_request(log Log) Log {
	return a.backend.create_log(Log{
		...log
		event: .http_request
		timestamp: time.now()
	})
}

// log_request logs http requests
pub fn (mut a Analyzer) get_logs(subject string) []Log {
	return []Log{}
}
