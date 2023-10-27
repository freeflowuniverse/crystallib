module hero

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools

// runs different session
// a session is a set of actions, can even load actions recursive
pub struct Runner {
pub mut:
	args     RunnerArgs
	path     pathlib.Path // is the base directory of the runner
	sessions []&Session
}

[params]
pub struct RunnerArgs {
pub mut:
	cid          string // circleid
	root         string // default ~/3bot/circles
	reset        bool   // will reset the content as fetched of url when true
	url          string // url can be ssh:// http(s):// git:// file:// path:// http(s)file://
	gitstructure ?gittools.GitStructure [skip; str: skip]
}

// open a runner a path is the only thing needed, config and everything else needs to come after
// a runner will get the actions from source and then load them in memory
pub fn new(args_ RunnerArgs) !Runner {
	mut args := args_
	if args.root == '' {
		args.root = '~/3bot/circles'
	}
	if args.cid == '' {
		args.cid = 'default'
	}
	if args.gitstructure == none {
		mut gs := gittools.get()!
		args.gitstructure = gs
	}

	mut r := Runner{
		path: pathlib.get_dir(path:'${args.root}/${args.cid}',create:true)!
		args: args
	}

	mut bootstrap_session := r.session_new(name: 'bootstrap', reset: args.reset)!

	if args.url.len > 0 {
		bootstrap_session.actions_add(downloadname: 'core', url: args.url, reset: args.reset)!
		bootstrap_session.run(actions_runner_config_enable: true)! // runner_config means we manipulate internals
	}
	// now the actions on bootstrap are the good ones
	return r
}

pub fn (mut r Runner) str() string {
	mut out := '## Runner\n\n'
	out += '> ${r.args.url}\n\n'
	for session in r.sessions {
		out += '${*session}\n'
	}
	return out
}

pub fn (mut r Runner) run() ! {
	for mut session in r.sessions {
		session.run()!
	}
}
