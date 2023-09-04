module hero

import freeflowuniverse.crystallib.pathlib

// runs different session
// a session is a set of actions, can even load actions recursive
pub struct Runner {
pub mut:
	args RunnerArgs
	path pathlib.Path // is the base directory of the runner
}

[params]
pub struct RunnerArgs {
pub mut:
	circle string
	root   string
	reset  bool   // will reset the content as fetched of url when true
	url    string // url can be ssh:// http(s):// git:// file:// path:// http(s)file://
}

// open a runner a path is the only thing needed, config and everything else needs to come after
// a runner will get the actions from source and then load them in memory
pub fn new(args_ RunnerArgs) !Runner {
	mut args := args_
	if args.root == '' {
		args.root = '~/3bot/circles'
	}
	if args.circle == '' {
		args.circle = 'default'
	}

	mut r := Runner{
		path: pathlib.get_dir('${args.root}/${args.circle}', true)!
		args: args
	}

	mut bootstrap_session := r.session_new(name: 'bootstrap', reset: args.reset)!

	if args.url.len > 0 {
		bootstrap_session.actions_add(url: args.url, reset: args.reset)!
		bootstrap_session.actions_run(actions_runner_config_enable: true)!
	}
	return r
}
