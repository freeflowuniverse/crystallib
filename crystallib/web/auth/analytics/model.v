module analytics

import time

pub struct Log {
	timestamp time.Time
pub mut:
	event   string
	subject string // an ID identifying the subject
	object  string // an ID identifying the object
	message string // a custom message that can be attached to a log
}

pub struct Event {
	name string
	description string
}

// // log_request logs http requests
// pub fn create_log(log Log) Log {
// 	return Log{
// 		...log
// 		timestamp: time.now()
// 	})
// }

// // log_request logs http requests
// pub fn (mut a Analyzer) get_logs(subject string) []Log {
// 	return []Log{}
// }
