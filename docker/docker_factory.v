module docker

import freeflowuniverse.crystallib.builder

[params]
pub struct DockerEngineArgs {
pub mut:
	sshkeys_allowed []string
	name            string = 'default'
	localonly       bool   // do you build for local utilization only
	prefix          string // e.g. despiegk/ or myimage registry-host:5000/despiegk/) is added to the name when pushing	
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
		prefix: args.prefix
		localonly: args.localonly
	}
	de.init()!
	return de
}
