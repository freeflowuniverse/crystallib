module zinit

import freeflowuniverse.crystallib.osal.systemd
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import os

@[heap]
pub struct Zinit {
pub mut:
	name string
	processes map[string]ZProcess
	path      pathlib.Path
	pathcmds  pathlib.Path
	pathtests pathlib.Path
}


pub fn (mut self Zinit) load() ! {

	cmd := 'zinit list'
	mut res := os.execute(cmd)
	if res.exit_code > 0 {
		if res.output.contains('failed to connect') {
			start()!
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


pub fn (mut self Zinit) check() bool {
	if !osal.cmd_exists('zinit') {
		return false
	}
	//println(osal.execute_ok('zinit list'))
	return osal.execute_ok('zinit list')
}



// remove all know services to zinit
pub fn (mut self Zinit)  destroy() ! {
	initd_proc_get(delete: true, start: false)!
	mut zinitpath := pathlib.get_dir(path: '/etc/zinit', create: true)!
	zinitpath.empty()!
	console.print_header(' zinit destroyed')
}

pub fn (mut self Zinit) start() ! {
	console.print_header('zinit start')
	initd_proc_get(delete: true, start: true)!
}


@[params]
struct InitDProcGet {
	delete bool
	start  bool = true
}

// start  it with systemd, because the zinit by itself needs to run somewhere
fn initd_proc_get(args InitDProcGet) !systemd.SystemdProcess {
	mut initdfactory := systemd.new()!
	mut initdprocess := initdfactory.new(
		cmd: '/usr/local/bin/zinit init'
		name: 'zinit'
		description: 'a super easy to use startup manager.'
	)!
	return initdprocess
}
