module docker

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.sshagent



// get docker engine directly linked to a name
pub fn engine_get(name string) !&DockerEngine {
	if name == '' {
		return error('need to specify name of docker engine')
	}

	if name in docker.docker_factory.dockerengines {
		get().current = name
		return get().dockerengines[name]
	}

	return error('cannot find dockerengine $name in docker_factory, please init.')
}

// if sshkeys_allowed empty array will check the local machine for loaded sshkeys
pub fn engine_local(sshkeys_allowed []string) !&DockerEngine {

	mut builder := builder.new()
	mut node := builder.node_local()!	

	return engine_new(name: 'local', node_name: node.name, sshkeys_allowed: sshkeys_allowed)
}

// the factory which returns an  docker engine//
//```
// pub struct DockerEngineArguments {
//	name 		string 			//the name of the docker engine
//	sshkeys_allowed []string 	// all keys here have access over ssh into the machine, when ssh enabled
//	node_name       string  	//name of the node on which the docker engine is running
// 	}
//```
pub fn engine_new(args DockerEngineArguments) !&DockerEngine {
	mut args2 := args

	if args2.sshkeys_allowed == [] {
		args2.sshkeys_allowed << sshagent.pubkey_guess()!
	}
	if args2.name == '' {
		return error('need to specify name')
	}

	if args2.name in docker.docker_factory.dockerengines {
		return docker.docker_factory.dockerengines[args2.name]
	}

	// not really needed is to check it works
	mut factory := builder.new()
	_ := factory.node_get(args2.node_name)!

	mut de := DockerEngine{
		name: args2.name
		node: args2.node_name
		sshkeys_allowed: args2.sshkeys_allowed
	}
	de.init()!

	get().dockerengines[args2.name] = &de
	get().current = args2.name

	return docker.docker_factory.dockerengines[args2.name]
}
