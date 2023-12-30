module play

import json

pub struct Base {
pub mut:
	session  ?&Session
	instance string
}

fn (mut self Base) session() !&Session {
	mut session := self.session or {
		mut s := session_new()!
		self.session = s
		s
	}

	return session
}
