module play

pub struct Base {
pub mut:
	session ?&Session @[skip; str: skip]
	name    string
}

fn (mut self Base) session() !&Session {
	mut session := self.session or {
		mut s := session_new()!
		self.session = s
		s
	}

	return session
}
