module docker

import os
import time
import builder
import arrays


[heap]
pub struct DockerFactory {
pub mut:
	dockerengines map[string]&DockerEngine
	//current engine
	current		string
}


//needed to get singleton
fn init_singleton() &DockerFactory {
	mut f := docker.DockerFactory{}	
	return &f
}

//singleton creation
const docker_factory = init_singleton()

struct DockerEngine {
pub mut:
	node            string "localhost"
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
}

pub struct DockerEngineArguments {
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
	node_name       string
}


pub fn docker_get(name string) ?&DockerEngine {

	if name==""{
		return error("need to specify name of docker engine")
	}

	if name in docker.docker_factory.dockerengines {
		docker.docker_factory.current = name
		return docker.docker_factory.dockerengines[name] 
	}


	return error("cannot find dockerengine $name in docker_factory, please init.")	

}

//get current docker engine intance
//if you want to switch uses docker_switch or docker_get
pub fn docker_current() ?&DockerEngine {
	return docker_get(	docker.docker_factory.current)
}

//switch you current docker engine
pub fn docker_switch(name string) ? {

	if name==""{
		return error("need to specify name of docker engine")
	}
	if name in docker.docker_factory.dockerengines {
		docker.docker_factory.current = name
		return
	}
	return error("cannot find dockerengine $name in docker_factory, please init.")	
}


//get docker engine directly linked to a name
pub fn docker_get(name string) ?&DockerEngine {

	if name==""{
		return error("need to specify name of docker engine")
	}

	if name in docker.docker_factory.dockerengines {
		docker.docker_factory.current = name
		return docker.docker_factory.dockerengines[name] 
	}


	return error("cannot find dockerengine $name in docker_factory, please init.")	

}

// the factory which returns an  docker engine//
//```
// pub struct DockerEngineArguments {
//	name 		string 			//the name of the docker engine
//	sshkeys_allowed []string 	// all keys here have access over ssh into the machine, when ssh enabled
//	node_name       string  	//name of the node on which the docker engine is running
// 	}
//```
pub fn docker_new(args DockerEngineArguments) ?&DockerEngine {


	if args.name==""{
		return error("need to specify name")
	}

	if name in docker.docker_factory.dockerengines {
		return docker.docker_factory.dockerengines[name] 
	}

	//not really needed is to check it works
	mut _ := builder.node_get(args.node_name) ?

	mut de := DockerEngine{
		node: args.node_name
		sshkeys_allowed: args.sshkeys_allowed
	}
	de.init()?

	docker.docker_factory.dockerengines[name] = &de
	docker.docker_factory.current = name

	return docker.docker_factory.dockerengines[name] 
}
