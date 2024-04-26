module base
import freeflowuniverse.crystallib.crypt.secrets
import v.reflection
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
fn (mut self BaseConfig[T]) configurator() !&Configurator[T] {
	mut configurator := self.configurator_ or {
		session := self.session_ or { return error('base config must be initialized') }

		mut c := configurator_new[T](
			context: &session.context
			instance: self.instance
		)!
		self.configurator_ = c
		c
	}

	return &configurator
}

//will overwrite the config
pub fn (mut self BaseConfig[T]) config_set(myconfig T) ! {
	self.config_ = &myconfig
	self.config_save()!
}

pub fn (mut self BaseConfig[T]) config() !&T {
	mut config := self.config_ or {
		mut configurator := self.configurator()!
		e := configurator.exists()!
		println('exists: ${configurator.config_key()} exists:${e}')
		mut c := configurator.get()!
		$for field in T.fields {
			field_attrs := attrs_get(field.attrs)
			if 'secret' in field_attrs {
				v:=c.$(field.name)
				c.$(field.name)=secrets.decrypt(v)!
				//println('FIELD DECRYPTED: ${field.name}')		
			}
		}		
		self.config_ = &c
		&c
	}

	return config
}

pub fn (mut self BaseConfig[T]) context() !&Context {
	mut configurator := self.configurator()!
	return configurator.context
}

pub fn (mut self BaseConfig[T]) config_save() ! {
	mut config2 := *self.config()! //dereference so we don't modify the original

	// //walk over the properties see where they need to be encrypted, if yes encrypt
	$for field in T.fields {
	 	field_attrs := attrs_get(field.attrs)
	 	if 'secret' in field_attrs {
	 		v:=config2.$(field.name)
		 	config2.$(field.name)=secrets.encrypt(v)!
	 		//println('FIELD ENCRYPTED: ${field.name}')		
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

@[params]
pub struct ConfigInitArgs {
pub mut:
	session  ?&Session
	session_new_args ?SessionNewArgs
	instance string = "default"
}


// init our class with the base session_args
pub fn (mut self BaseConfig[T]) init(args ConfigInitArgs) ! {
	mut session_new_args := args.session_new_args or {
		mut session_new_args0 := SessionNewArgs{}
		session_new_args0
	}

	if self.instance == '' {
		self.instance = args.instance
	}

	mut session := args.session or {
		mut s := session_new(session_new_args)!
		s
	}

	self.session_ = session

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
