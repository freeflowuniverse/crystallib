module docker

import freeflowuniverse.crystallib.builder

[params]
pub struct DockerEngineArgs {
pub mut:
	sshkeys_allowed []string
	name            string
}

// if sshkeys_allowed empty array will check the local machine for loaded sshkeys
pub fn new(args DockerEngineArgs) !DockerEngine {
	mut args2 := args
	if args2.name == '' {
		args2.name = 'local'
	}
	mut node := builder.node_local()!
	mut de := DockerEngine{
		name: args2.name
		node: node
		sshkeys_allowed: args2.sshkeys_allowed
	}
	de.init()!
	return de
}
