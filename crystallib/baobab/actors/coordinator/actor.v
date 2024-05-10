module coordinator

import freeflowuniverse.crystallib.baobab.actor

struct Coordinator {
	actor.Actor
}

pub fn get(config actor.ActorConfig) !Coordinator {
	return Coordinator{
		Actor: actor.new(config)!
	}
}
