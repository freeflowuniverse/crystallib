module accountant

import freeflowuniverse.crystallib.baobab.actor

pub struct Accountant {
	actor.Actor
}

pub fn get(config actor.ActorConfig) !Accountant {
	return Accountant{
		Actor: actor.new(config)!
	}
}
