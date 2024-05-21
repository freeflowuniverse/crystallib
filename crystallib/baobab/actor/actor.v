module actor

import freeflowuniverse.crystallib.baobab.backend

pub struct Actor {
mut:
	backend backend.Backend
}

pub struct ActorConfig {
	backend.BackendConfig
}

pub fn new(config ActorConfig) !Actor {
	return Actor{
		backend: backend.new(config.BackendConfig)!
	}
}
