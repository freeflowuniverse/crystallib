module analytics

import os

const test_db = 'analyzer_test.sqlite'

fn testsuite_begin() {
	if os.exists(analytics.test_db) {
		os.rm(analytics.test_db)!
	}
}

fn test_new() {
	analyzer := new()!
}

pub fn test_log() ! {
	mut analyzer := new(
		backend: new_backend(db_path: analytics.test_db)!
	)!
	analyzer.log(
		subject: 'test_requester'
		object: '/test/url'
		event: .http_request
	)
}
