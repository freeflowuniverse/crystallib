module play

pub struct BaseConfig[T] {
mut:
	configurator_ ?Configurator[T] @[skip; str: skip]
	session_      ?&Session        @[skip; str: skip]
	config_       ?&T
pub mut:
	instance string
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
pub fn (mut self BaseConfig[T]) session_set(args PlayArgs) !&Session {
	mut s := session_new(args)!
	self.session_ = s
	return s
}

pub fn (mut self BaseConfig[T]) session() !&Session {
	mut session := self.session_ or { panic('bug init needs to be called before') }
	return session
}

pub fn (mut self BaseConfig[T]) context() !&Context {
	mut session := self.session()!
	return &session.context
}

// management class of the configs of this obj
pub fn (mut self BaseConfig[T]) configurator() !&Configurator[T] {
	mut configurator := self.configurator_ or {
		mut c := configurator_new[T](
			context: self.context()!
			instance: self.instance
		)!
		self.configurator_ = c
		c
	}

	return &configurator
}

pub fn (mut self BaseConfig[T]) config() !&T {
	mut config := self.config_ or {
		mut configurator := self.configurator()!
		e := configurator.exists()!
		println('exists: ${configurator.config_key()} exists:${e}')
		mut c := configurator.get()!
		self.config_ = &c
		&c
	}

	return config
}

pub fn (mut self BaseConfig[T]) config_save() ! {
	mut config := self.config()!
	mut configurator := self.configurator()!
	configurator.set(config)!
}

pub fn (mut self BaseConfig[T]) config_delete() ! {
	mut configurator := self.configurator()!
	configurator.delete()!
	self.config_ = none
}

// init our class with the base playargs
pub fn (mut self BaseConfig[T]) init(playargs ?PlayArgs) ! {
	mut plargs := playargs or {
		mut plargs0 := PlayArgs{}
		plargs0
	}

	if self.instance == '' {
		self.instance = plargs.instance
	}
	mut session := plargs.session or {
		mut s := session_new(plargs)!
		s
	}

	self.session_ = session
}
