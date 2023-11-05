module zinit

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct Zinit {
pub mut:
	processes map[string]ZProcess
	path      pathlib.Path
	pathcmds  pathlib.Path
	pathtests pathlib.Path
}

pub fn new() !Zinit {
	mut obj := Zinit{
		path: pathlib.get_dir(path: '/etc/zinit', create: true)!
		pathcmds: pathlib.get_dir(path: '/etc/zinit/cmds', create: true)!
		pathtests: pathlib.get_dir(path: '/etc/zinit/tests', create: true)!
	}

	cmd := 'zinit list'
	r := osal.execute_silent(cmd)!
	mut state := ''
	for line in r.split_into_lines() {
		if line.starts_with('---') {
			state = 'ok'
			continue
		}
		if state == 'ok' && line.contains(':') {
			name := line.split(':')[0].to_lower().trim_space()
			mut zp := ZProcess{
				name: name
				zinit: &obj
			}
			zp.load()!
			obj.processes[name] = zp
		}
	}
	return obj
}

[params]
pub struct ZProcessNewArgs {
pub mut:
	name      string            [required]
	cmd       string            [required]
	cmd_file  bool
	test      string
	test_file bool
	after     []string
	env       map[string]string
	oneshot   bool
}

pub fn (mut zinit Zinit) new(mut args_ ZProcessNewArgs) !ZProcess {
	mut args := args_

	mut zp := ZProcess{
		name: args.name
		zinit: &zinit
	}

	if args.cmd.contains('\n') || args.cmd_file {
		// means we can load the special cmd
		mut pathcmd := zinit.pathcmds.file_get(args.name)!
		pathcmd.write(args.cmd)!
		zp.cmd = args.cmd
	}

	if args.test.contains('\n') || args.test_file {
		// means we can load the special cmd
		mut pathcmd := zinit.pathtests.file_get(args.name)!
		pathcmd.write(args.test)!
		zp.test = args.test
	}

	zp.oneshot = args.oneshot
	zp.env = args.env.move()
	zp.after = args.after

	mut pathyaml := zinit.path.file_get(zp.name + '.yaml')!
	pathyaml.write(zp.str())!

	zinit.processes[args.name] = zp

	return zp
}
