module publisher

import freeflowuniverse.crystallib.baobab.actor
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.web.caddy as caddyinstaller
import os

pub struct Publisher[T] {
	actor.Actor
	base.BaseConfig[T]
}

@[params]
pub struct Config {
pub mut:
	source_path string
	build_path string
}

pub fn get(instance string) !Publisher[Config] {
	mut self := Publisher[Config]{}
	self.init('publisher', instance, .get)!
	return self
}

// set the configuration, will make defaults for passwd & secret
pub fn configure(instance string, cfg_ Config) !Publisher[Config] {
	mut cfg := cfg_
	mut self := Publisher[Config]{}
	self.init('publisher', instance, .set, cfg)!

	return self
}