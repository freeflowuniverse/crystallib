module play

import json

pub struct Configurator[T] {
pub mut:
	context  &Context
	name     string // e.g. sshclient
	instance string
}

@[params]
pub struct ConfiguratorArgs {
pub mut:
	context  &Context
	name     string
	instance string
}

// name is e.g. mailclient (the type of configuration setting)
// instance is the instance of the config e.g. kds
// the context defines the context in which we operate
pub fn configurator_new[T](args ConfiguratorArgs) !Configurator[T] {
	return Configurator[T]{
		context: args.context
		name: args.name
		instance: args.instance
	}
}

fn (mut self Configurator[T]) config_key() string {
	return '${self.name}_config_${self.instance}'
}

pub fn (mut self Configurator[T]) set(args_ T) ! {
	mut args := args_
	args.instance = self.instance
	mut kvs := self.context.db_config_get()!
	data := json.encode_pretty(args)
	kvs.set(self.config_key(), data)!
}

pub fn (mut self Configurator[T]) get() !T {
	mut kvs := self.context.db_config_get()!
	if !kvs.exists(self.config_key()) {
		return error("can't find configuration with name: ${self.config_key()}")
	}
	data := kvs.get(self.config_key())!
	return json.decode(T, data)!
}

pub fn (mut self Configurator[T]) reset() ! {
	mut kvs := self.context.db_config_get()!
	kvs.delete(self.config_key())!
}

pub fn (mut self Configurator[T]) getset(args T) !T {
	mut kvs := self.context.db_config_get()!
	if kvs.exists(self.config_key()) {
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
	mut kvs := self.context.db_config_get()!
	if args.name.len > 0 {
		if kvs.exists(self.config_key()) {
			data := kvs.get(self.config_key())!
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
