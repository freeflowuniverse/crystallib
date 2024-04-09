module base

import json

@[heap]
pub struct ConfigBase {
pub mut:
	context     &Context @[skip; str: skip]
	instance    string
	description string
	configured  bool
}

@[heap]
pub struct Configurator[T] {
	ConfigBase
	configtype string // e.g. sshclient
}

@[params]
pub struct ConfiguratorArgs {
pub mut:
	context  &Context
	instance string   @[required]
}

// name is e.g. mailclient (the type of configuration setting)
// instance is the instance of the config e.g. kds
// the context defines the context in which we operate, is optional will get the default one if not set
pub fn configurator_new[T](args ConfiguratorArgs) !Configurator[T] {
	return Configurator[T]{
		context: args.context
		configtype: T{}.configtype
		instance: args.instance
	}
}

fn (mut self Configurator[T]) config_key() string {
	return '${self.configtype}_config_${self.instance}'
}

// set the full configuration as one object to dbconfig
pub fn (mut self Configurator[T]) set(args_ T) ! {
	mut args := args_
	args.instance = self.instance
	mut db := self.context.db_config_get()!
	data := json.encode_pretty(args)
	db.set(self.config_key(), data)!
}

pub fn (mut self Configurator[T]) exists() !bool {
	mut db := self.context.db_config_get()!
	return db.exists(self.config_key())
}

pub fn (mut self Configurator[T]) get() !T {
	mut db := self.context.db_config_get()!
	if !db.exists(self.config_key()) {
		return T{
			instance: self.instance
			description: self.description
		}
		// return error("can't find configuration with name: ${self.config_key()} in context:'${self.context.name}'")
	}
	data := dbcollection.get(self.config_key())!
	return json.decode(T, data)!
}

pub fn (mut self Configurator[T]) delete() ! {
	mut db := self.context.db_config_get()!
	db.delete(self.config_key())!
}

pub fn (mut self Configurator[T]) getset(args T) !T {
	mut db := self.context.db_config_get()!
	if db.exists(self.config_key()) {
		return self.get()!
	}
	self.set(args)!
	return self.get()!
}

@[params]
pub struct PrintArgs {
pub mut:
	name string
}

pub fn (mut self Configurator[T]) list() ![]string {
	panic('implement')
}

pub fn (mut self Configurator[T]) configprint(args PrintArgs) ! {
	mut db := self.context.db_config_get()!
	if args.name.len > 0 {
		if db.exists(self.config_key()) {
			data := dbcollection.get(self.config_key())!
			c := json.decode(T, data)!
			println(c)
			println('')
		} else {
			return error("Can't find connection with name: ${args.name}")
		}
	} else {
		panic('implement')
		// for item in list()! {
		// 	// println(" ==== $item")
		// 	configprint(name: item)!
		// }
	}
}

// init our class with the base playargs
// pub fn (mut self Configurator[T]) init(playargs_ PlayArgs) ! {
// 	self.session_=playargs.session or {
// 		session_new(playargs)!
// 	 }
// }
