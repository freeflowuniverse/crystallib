module base

@[heap]
pub struct Base {
mut:
	session_ ?&Session
}

// return a session which has link to the actions and params on context and session level
// the session also has link to dbfs (filesystem key val stor and gitstructure if relevant)
//```
// context             ?&Context      @[skip; str: skip]
// session             ?&Session      @[skip; str: skip]
// context_name        string = 'default'
// session_name        string //default will be based on a date when run
// interactive         bool = true //can ask questions, default on true
// coderoot            string //this will define where all code is checked out
//```
pub fn (mut self Base) session(args SessionNewArgs) !&Session {
	mut mysession := self.session_ or {
		mut s := session_new(args)! // or { panic("can't get session with args:${args}") }
		self.session_ = s
		s
	}

	return mysession
}

pub fn (mut self Base) context() !&Context {
	mut session := self.session()!
	return &session.context
}
