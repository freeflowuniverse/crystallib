module base


@[heap]
pub struct Base {
	configtype string @[required]
mut:
	instance string
	session_ ?&Session
}

pub fn (mut self Base) session() !&Session {
	mut mysession := self.session_ or {
		mut c := context()!
		mut r := c.redis()!
		incrkey := 'sessions:base:latest:${self.type_name}:${self.instance}'
		latestid:=r.incr(incrkey)!
		name:="${self.type_name}_${self.instance}_${latestid}"
		mut s:=c.session_new(name:name)!
		self.session_ = &s
		&s
	}
	return mysession
}

