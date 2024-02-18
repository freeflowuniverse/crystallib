module play

@[heap]
pub struct Base {
mut:
	session_ ?&Session
}

pub fn (mut self Base) session() !&Session {
	mut mysession := self.session_ or {
		mut s := session_new()!
		self.session_ = s
		s
	}

	return mysession
}
