module coordinator

import freeflowuniverse.crystallib.baobab.actor

pub struct Coordinator {
	actor.Actor
}

pub fn get(config actor.ActorConfig) !Coordinator {
	return Coordinator{
		Actor: actor.new(config)!
	}
}
