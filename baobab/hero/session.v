module hero

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

// a session is where in execute on actions inside a runner, a runner can have multiple sessions
pub struct Session {
pub mut:
	name     string
	path     pathlib.Path      [skip] // is the base directory of the session
	vars     map[string]string
	actions  []actions.Action  [skip]
	includes []string
	runner   &Runner           [skip; str: skip]
}

[params]
pub struct SessionArgs {
pub mut:
	name  string
	reset bool // will reset the content as fetched of url when true	
}

// open a runner a path is the only thing needed, config and everything else needs to come after
// a runner will get the actions from source and then load them in memory
pub fn (mut r Runner) session_new(args_ SessionArgs) !Session {
	mut args := args_

	if args.name.len == 0 {
		return error('Cannot execute session for runner, name not defined.\n${r}')
	}

	args.name = texttools.name_fix(args.name)

	mut session := Session{
		runner: &r
		name: args.name
		path: pathlib.get_dir('${r.path.path}/sessions/${args.name}', true)!
	}
	return session
}

[params]
pub struct ActionsAddArgs {
pub mut:
	name  string
	reset bool   // will reset the content as fetched of url when true
	url   string // url can be ssh:// http(s):// git:// file:// path:// http(s)file://	
}

pub fn (mut session Session) actions_add(args_ ActionsAddArgs) ! {
	mut args := args_

	if args.url.len < 5 {
		return error("Cannot execute session '${session.name}' for runner, url not defined.\n${session}")
	}

	args.name = texttools.name_fix(args.name)

	mut recipes_path := pathlib.get_dir('${session.path.path}/recipes', false)!
	if args.name.len > 0 {
		recipes_path = pathlib.get_dir('${session.path.path}/recipes_${args.name}', false)!
	}
	if args.reset == false && recipes_path.exists() {
		return error("cannot add actions if reset=false and dir:'${recipes_path.path}' exists.")
	}
	if args.reset {
		recipes_path.empty()!
	}

	download_result := download(
		url: args.url
		reset: args.reset
		dest: recipes_path.path // is now a dir so files will get in dir
	)!
	mut download_path := pathlib.get_dir(download_result.path, false)!

	mut ap := actions.new(path: download_path.path)!
	for a in ap.actions {
		session.actions << a
	}
}

[params]
pub struct ActionLoadArgs {
pub mut:
	actions_runner_config_enable bool
}

// run the recipes but on
pub fn (mut s Session) actions_run(args ActionLoadArgs) ! {
	// lets first resolve the includes and process after including
	mut actionsprocessed := s.actions_include(s.actions)!

	for mut action in actionsprocessed {
		if action.actor == 'runner' && action.name == 'config' {
			if args.actions_runner_config_enable {
				// only execute when we load the runner
				mut circle := action.params.get_default('circle', '')!
				mut root := action.params.get_default('root', '')!
				if circle.len > 0 {
					s.runner.args.circle = circle
				}
				if root.len > 0 {
					s.runner.args.root = root
				}
				s.runner.path = pathlib.get_dir('${s.runner.args.root}/${s.runner.args.circle}',
					true)!
			}
		} else if (action.actor == 'runner' || action.actor == 'session')
			&& action.name == 'var_set' {
			mut name := action.params.get_default('name', '')!
			mut val := action.params.get_default('val', '')!
			if name == '' || val == '' {
				return error('Name or val not specified in ${action}.\n${s}')
			}
			s.var_set(name, val)
		} else if (action.actor == 'runner' || action.actor == 'session')
			&& action.name == 'recipe_add' {
			// will add an action can be https file, https git, scp, or local path
			//!!runner.recipe_add source:'${ROOT}/core/base0' aname:'base0' execute:1
			actionsprocessed << action
			// TODO:
		} else {
			actionsprocessed << action
		}
	}

	// now resolve all the variables
	for mut action in actionsprocessed {
		// action.params.replace(test)
		action.params.replace(s.vars)
		println(action.params)
	}
	s.actions = actionsprocessed
}

pub fn (mut s Session) var_set(name string, value string) {
	name2 := texttools.name_fix(name)
	s.vars[name2] = value
}

pub fn (mut s Session) var_get(name string) !string {
	name2 := texttools.name_fix(name)
	if name2 in s.vars {
		return s.vars[name2]
	}
	return error('Could not find ${name} in vars of runner.\n${s}')
}

pub fn (mut s Session) var_exists(name string) bool {
	name2 := texttools.name_fix(name)
	if name2 in s.vars {
		return true
	}
	return false
}
