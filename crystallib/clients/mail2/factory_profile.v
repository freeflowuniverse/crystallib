module mail

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

pub struct MailProfile[T] {
	base.BaseConfig[T]
}

pub struct MailProfileConfig {
pub mut:
	client_instance string @[required]
	mail_from       string @[required]
	mail_to         string
	prefix          string
}

// create a new profile for mail
pub fn new(instance string, myconfig MailProfileConfig) !MailProfile[MailProfileConfig] {
	mut self := get(instance)!
	self.config_set(myconfig)!
	return self
}

pub fn get(instance string) !MailProfile[MailProfileConfig] {
	mut self := MailProfile[MailProfileConfig]{}
	self.init(instance: instance)!
	return self
}
