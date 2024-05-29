module base
// import freeflowuniverse.crystallib.ui.console

// is an object which has a configurator, session and config object which is unique for the model
// T is the Config Object

pub struct BaseConfig[T] {
mut:
	configurator_ ?Configurator[T] @[skip; str: skip]
	config_       ?&T
	session_      ?&Session        @[skip; str: skip]
	configtype    string
pub mut:
	instance string
}

pub fn (mut self BaseConfig[T]) session() !&Session {
	mut mysession := self.session_ or {
		mut c := context()!
		mut r := c.redis()!
		incrkey := 'sessions:base:latest:${self.configtype}:${self.instance}'
		latestid := r.incr(incrkey)!
		name := '${self.configtype}_${self.instance}_${latestid}'
		mut s := c.session_new(name: name)!
		self.session_ = &s
		&s
	}

	return mysession
}

// management class of the configs of this obj
pub fn (mut self BaseConfig[T]) configurator() !&Configurator[T] {
	mut configurator := self.configurator_ or {
		// session := self.session_ or { return error('base config must be initialized') }
		mut c := configurator_new[T](
			instance: self.instance
		)!
		self.configurator_ = c
		c
	}

	return &configurator
}

// will overwrite the config
pub fn (mut self BaseConfig[T]) config_set(myconfig T) ! {
	self.config_ = &myconfig
	self.config_save()!
}

pub fn (mut self BaseConfig[T]) config_new() !&T {
	mut config := self.config_ or {
		mut configurator := self.configurator()!
		mut c := configurator.new()!
		self.config_ = &c
		&c
	}

	self.config_save()!
	return config
}

pub fn (mut self BaseConfig[T]) config() !&T {
	mut config := self.config_ or { return error('config was not initialized yet') }

	return config
}

pub fn (mut self BaseConfig[T]) config_get() !&T {
	mut mycontext := context()!
	mut config := self.config_ or {
		mut configurator := self.configurator()!
		if !(configurator.exists()!) {
			mut mycfg := self.config_new()!
			return mycfg
		}
		mut c := configurator.get()!
		$for field in T.fields {
			field_attrs := attrs_get(field.attrs)
			if 'secret' in field_attrs {
				v := c.$(field.name)
				c.$(field.name) = mycontext.secret_decrypt(v)!
				// console.print_debug('FIELD DECRYPTED: ${field.name}')		
			}
		}
		self.config_ = &c
		&c
	}

	return config
}

pub fn (mut self BaseConfig[T]) config_save() ! {
	mut config2 := *self.config_get()! // dereference so we don't modify the original
	mut mycontext := context()!
	// //walk over the properties see where they need to be encrypted, if yes encrypt
	$for field in T.fields {
		field_attrs := attrs_get(field.attrs)
		if 'secret' in field_attrs {
			v := config2.$(field.name)
			config2.$(field.name) = mycontext.secret_encrypt(v)!
			// console.print_debug('FIELD ENCRYPTED: ${field.name}')		
		}
	}
	mut configurator := self.configurator()!
	configurator.set(config2)!
}

pub fn (mut self BaseConfig[T]) config_delete() ! {
	mut configurator := self.configurator()!
	configurator.delete()!
	self.config_ = none
}

pub enum Action {
	set
	get
	new
	delete
}

// init our class with the base session_args
pub fn (mut self BaseConfig[T]) init(configtype string, instance string, action Action, myconfig T) ! {
	self.instance = instance
	self.configtype = configtype
	if action == .get {
		self.config_get()!
	} else if action == .new {
		self.config_new()!
	} else if action == .delete {
		self.config_delete()!
	} else if action == .set {
		self.config_set(myconfig)!
	} else {
		panic('bug')
	}
}

// will return {'name': 'teststruct', 'params': ''}
fn attrs_get(attrs []string) map[string]string {
	mut out := map[string]string{}
	for i in attrs {
		if i.contains('=') {
			kv := i.split('=')
			out[kv[0].trim_space().to_lower()] = kv[1].trim_space().to_lower()
		} else {
			out[i.trim_space().to_lower()] = ''
		}
	}
	return out
}
