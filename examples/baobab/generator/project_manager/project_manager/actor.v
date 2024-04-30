module testactor
import freeflowuniverse.crystallib.baobab.actor 

struct TestActor {
	actor.Actor
}

//
pub fn get(config actor.ActorConfig) !TestActor {
	return TestActor{
		Actor: actor.new(config)!
	}
}