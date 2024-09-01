module zinit

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.ourtime
import os

@[heap]
pub struct Zinit {
pub mut:
	processes map[string]ZProcess
	path      pathlib.Path
	pathcmds  pathlib.Path
	pathtests pathlib.Path
}


//will delete the process if it exists while starting
pub fn (mut zinit Zinit) new(args_ ZProcessNewArgs) !ZProcess {

	console.print_header(' zinit process new')
	mut args:=args_

	if args.cmd.len == 0 {
		$if debug {
			print_backtrace()
		}
		return error('cmd cannot be empty for ${args} in zinit.')
	}

	if zinit.exists(args.name) {
		mut p := zinit.get(args.name)!
		p.destroy()!
	}

	mut zp := ZProcess{
		name: args.name
		cmd: args.cmd
	}

	// means we can load the special cmd
	mut pathcmd := zinit.pathcmds.file_get_new(args.name + '.sh')!

	zp.cmd = 'echo === START ======== ${ourtime.now().str()} === \n' + texttools.dedent(zp.cmd) + "\n"
	pathcmd.write(zp.cmd)!
	pathcmd.chmod(0x770)!
	zp.cmd = '/bin/bash -c ${pathcmd.path}'

	if args.test.len > 0 {
		if args.test.contains('\n'){
			// means we can load the special cmd
			mut pathcmd2 := zinit.pathtests.file_get_new(args.name + '.sh')!
			args.test = texttools.dedent(args.test)
			pathcmd2.write(args.test)!
			pathcmd2.chmod(0x770)!
			zp.test = '/bin/bash -c ${pathcmd2.path}'
		}
	}

	zp.oneshot = args.oneshot
	zp.env = args.env.move()
	zp.after = args.after
	mut pathyaml := zinit.path.file_get_new(zp.name + '.yaml')!
	// console.print_debug('debug zprocess path yaml: ${pathyaml}')
	pathyaml.write(zp.config_content())!
	if args.start{
		zp.start()!
	}
	zinit.processes[args.name] = zp

	return zp
}

pub fn (mut zinit Zinit) get(name_ string) !ZProcess {
	name := texttools.name_fix(name_)
	// console.print_debug(zinit)
	return zinit.processes[name] or { return error("cannot find process in zinit:'${name}'") }
}

pub fn (mut zinit Zinit) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	if name in zinit.processes {
		return true
	}
	return false
}

pub fn (mut zinit Zinit) stop(name string) ! {
	mut p:=zinit.get(name)!
	p.stop()!
}

pub fn (mut zinit Zinit) start(name string) ! {
	mut p:=zinit.get(name)!
	p.start()!
}

pub fn (mut zinit Zinit) delete(name string) ! {
	mut p:=zinit.get(name)!
	p.destroy()!
}


pub fn (mut self Zinit) load() ! {

	cmd := 'zinit list'
	mut res := os.execute(cmd)
	if res.exit_code > 0 {
		if res.output.contains('failed to connect') {
			self.systemd_start()!
			res = os.execute(cmd)
			if res.exit_code > 0 {
				$if debug {
					print_backtrace()
				}
				return error("can't do zinit list, after start of zinit.\n${res}")
			}
		} else {
			$if debug {
				print_backtrace()
			}
			return error("can't do zinit list.\n${res}")
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
			}
			zp.load()!
			self.processes[name] = zp
		}
	}
}

