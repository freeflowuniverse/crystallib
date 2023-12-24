module play

import json

pub struct Base {
pub mut:
	session ?&Session
	instance string
}


fn (mut self Base) session() !&Session {	
	mut session := self.session or {
			mut s:=session_new()!
			self.session=s
			s
		}
	return session
}


pub struct Configurator[T] {
pub mut:
	session &Session
	name string	 //e.g. sshclient
	instance string
}


@[params]
pub struct ConfiguratorArgs {
pub mut:
	name string
	instance string
	playargs ?PlayArgs
}


pub fn configurator_new[T](args ConfiguratorArgs) !Configurator[T] {
	playargs:=args.playargs or {PlayArgs{}}
	mut session:=play.session_new(playargs)!		
    return Configurator[T]{
		session:session
		instance:args.instance
		name:args.name
	}
}

pub fn (mut self Configurator[T]) config_key() string {
	return "${self.name}_config_${self.instance}"
}

pub fn (mut self Configurator[T]) set(args_ T) ! {
	mut args:=args_
	args.instance = self.instance
	mut kvs:=self.session.db_config_get()!
	data := json.encode_pretty(args)
	kvs.set(self.config_key(), data)!
}

pub fn (mut self Configurator[T]) get() !T {
	mut kvs:=self.session.db_config_get()!
	if !kvs.exists(self.config_key()) {
		return error("can't find configuration with name: ${self.config_key()}")
	}
	data := kvs.get(self.config_key())!
	return json.decode(T, data)!
}

pub fn (mut self Configurator[T]) reset() ! {
	mut kvs:=self.session.db_config_get()!
	kvs.delete(self.config_key())!
}

pub fn (mut self Configurator[T]) getset(args T) !T {
	mut kvs:=self.session.db_config_get()!
	if kvs.exists(self.config_key()){
		return self.get()!
	}
	self.set(args)!
	return self.get()!
}
