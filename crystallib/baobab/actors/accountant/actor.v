module accountant

import freeflowuniverse.crystallib.baobab.actor

struct Accountant {
	actor.Actor
}

//
pub fn get(config actor.ActorConfig) !Accountant {
	return Accountant{
		Actor: actor.new(config)!
	}
}
