module sshagent

import os
import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct SSHAgentNewArgs {
pub mut:
	homepath string
}

pub fn new(args_ SSHAgentNewArgs) !SSHAgent {
	mut args := args_
	if args.homepath.len == 0 {
		args.homepath = '${os.home_dir()}/.ssh'
	}

	mut agent := SSHAgent{
		homepath: pathlib.get_dir(path: args.homepath, create: true)!
	}
	res := os.execute('ssh-add -l')
	if res.exit_code == 0 {
		agent.active = true
	}
	agent.init()! // loads the keys known on fs and in ssh-agent
	return agent
}

pub fn loaded() bool {
	mut agent := new() or { panic(err) }
	return agent.active
}
