module juggler

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.develop.gittools

// Juggler is a Continuous Integration Juggler that listens for triggers from gitea repositories.
pub struct Juggler[T] {
	base.BaseConfig[T]
}

@[params]
pub struct Config {
pub mut:
	repo_url string
	host string = 'localhost' @[required]
	port int = 8888 @[required]
	// dagu_urls []string = ['http://localhost:8200'] 
	dagu_url string = 'http://localhost:8200' 
}

pub struct JugglerGetArgs {
	gittools.ReposGetArgs
}

pub fn get(instance string) !Juggler[Config] {
	mut self := Juggler[Config]{}

	c := caddy.get(instance)!
	c.start()!

	self.init('juggler', instance, .get)!
	return self
}

// set the configuration, will make defaults for passwd & secret
pub fn configure(instance string, cfg_ Config) !Juggler[Config] {
	mut cfg := cfg_
	mut self := Juggler[Config]{}

	self.init('juggler', instance, .set, cfg)!
	return self
}

