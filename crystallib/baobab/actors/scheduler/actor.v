module scheduler

import freeflowuniverse.crystallib.baobab.actor

pub struct Scheduler {
	actor.Actor
}

pub fn get(config actor.ActorConfig) !Scheduler {
	return Scheduler{
		Actor: actor.new(config)!
	}
}
