module base

// is an object which has a configurator, session and config object which is unique for the model
// T is the Config Object
pub struct BaseConfig[T] {
mut:
	configurator_ ?Configurator[T] @[skip; str: skip]
	session_      ?&Session        @[skip; str: skip]
	config_       ?&T
pub mut:
	instance string
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
