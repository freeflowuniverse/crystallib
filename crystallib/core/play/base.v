module play

pub struct Base {
pub mut:
	session_ ?&Session @[skip; str: skip]
	instance    string
}


@[params]
pub struct InstanceNewArgs {
pub mut:
	instance string  = "default"
	playargs ?PlayArgs
}


// return a session which has link to the actions and params on context and session level
// the session also has link to fskvs (filesystem key val stor and gitstructure if relevant)
//```
// context             ?&Context      @[skip; str: skip]
// session             ?&Session      @[skip; str: skip]
// context_name        string = 'default'
// session_name        string //default will be based on a date when run
// interactive         bool = true //can ask questions, default on true
// coderoot            string //this will define where all code is checked out
// playbook_url                 string //url of heroscript to get and execute in current context
// playbook_path                string //path of heroscript to get and execute
// playbook_text                string //heroscript to execute
//```
pub fn (mut self Base) session_set(args PlayArgs) !&Session {
	mut s := session_new(args)!
	self.session_=s
	return s
}

pub fn (mut self Base) session() !&Session {
	mut session := self.session_ or {
		mut s := session_new()!
		self.session_ = s
		s
	}
	return session
}

pub fn (mut self Base) context() !&Context {
	mut session := self.session()!
	return &session.context
}
