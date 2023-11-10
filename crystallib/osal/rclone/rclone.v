module rclone

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.initd
import freeflowuniverse.crystallib.core.pathlib
import os

[heap]
pub struct Zinit {
pub mut:
	processes map[string]ZProcess
	path      pathlib.Path
	pathcmds  pathlib.Path
	pathtests pathlib.Path
}

[params]
struct InitDProcGet {
	delete bool
	start  bool = true
}


// pub fn start() ! {
// 	println(' - rclone start')
// 	initd_proc_get(delete: true, start: true)!
// }

pub fn new() !Zinit {
	mut obj := Zinit{
		path: pathlib.get_dir(path: '/etc/rclone', create: true)!
		pathcmds: pathlib.get_dir(path: '/etc/rclone/cmds', create: true)!
		pathtests: pathlib.get_dir(path: '/etc/rclone/tests', create: true)!
	}

	cmd := 'rclone list'
	mut res := os.execute(cmd)
	if res.exit_code > 0 {
		if res.output.contains('failed to connect') {
			start()!
			res = os.execute(cmd)
			if res.exit_code > 0 {
				return error("can't do rclone list, after start of rclone.\n${res}")
			}
		} else {
			return error("can't do rclone list.\n${res}")
		}
	}
	mut state := ''
	for line in res.output.split_into_lines() {
		if line.starts_with('---') {
			state = 'ok'
			continue
		}
		if state == 'ok' && line.contains(':') {
			name := line.split(':')[0].to_lower().trim_space()
			mut zp := ZProcess{
				name: name
				rclone: &obj
			}
			zp.load()!
			obj.processes[name] = zp
		}
	}
	// println(obj)
	return obj
}

[params]
pub struct ZProcessNewArgs {
pub mut:
	name      string            [required]
	cmd       string            [required]
	cmd_file  bool // if we wanna force to run it as a file which is given to bash -c  (not just a cmd in rclone)
	test      string
	test_file bool
	after     []string
	env       map[string]string
	oneshot   bool
}

pub fn (mut rclone Zinit) new(args_ ZProcessNewArgs) !ZProcess {
	mut args := args_

	mut zp := ZProcess{
		name: args.name
		rclone: &rclone
	}

	if args.cmd.contains('\n') || args.cmd_file {
		// means we can load the special cmd
		mut pathcmd := rclone.pathcmds.file_get(args.name)!
		pathcmd.write(args.cmd)!
		// zp.cmd = "/bin/bash -c ${pathcmd.path}"
	}

	if args.test.contains('\n') || args.test_file {
		// means we can load the special cmd
		mut pathcmd := rclone.pathtests.file_get(args.name)!
		pathcmd.write(args.test)!
		// zp.test = "/bin/bash -c ${pathcmd.path}"
	}

	zp.oneshot = args.oneshot
	zp.env = args.env.move()
	zp.after = args.after

	mut pathyaml := rclone.path.file_get(zp.name + '.yaml')!
	pathyaml.write(zp.str())!

	rclone.processes[args.name] = zp

	return zp
}
