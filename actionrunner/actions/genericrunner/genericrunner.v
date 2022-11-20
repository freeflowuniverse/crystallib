module runner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.gittools { GitStructure }

struct Runner {
	channel chan u32
}

pub fn new_runner() Runner {
	mut runner := Runner{
	}
	return runner
}

fn (mut runner Runner) run() {
	mut msg := ActionJob{}
	for {
		jobid = <- runner.channel
		match action.name {
			'git.params.multibranch' { runner.run_multibranch(mut job) }
			'git.pull' { runner.run_pull(mut job) }
			'git.link' { runner.run_link(mut job) }
			else { panic('Gitrunner received unhandled action') }
		}
	}
}

