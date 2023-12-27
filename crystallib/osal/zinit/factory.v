module zinit

// import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
import os

// will initialize a zinit session and start it when needed
pub fn new() !Zinit {
	mut obj := Zinit{
		path: pathlib.get_dir(path: '/etc/zinit', create: true)!
		pathcmds: pathlib.get_dir(path: '/etc/zinit/cmds', create: true)!
		pathtests: pathlib.get_dir(path: '/etc/zinit/tests', create: true)!
	}

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
				zinit: &obj
			}
			zp.load() or {}
			obj.processes[name] = zp
		}
	}
	// println(obj)
	return obj
}

// remove all know services to zinit
pub fn destroy() ! {
	initd_proc_get(delete: true, start: false)!
	mut zinitpath := pathlib.get_dir(path: '/etc/zinit', create: true)!
	zinitpath.empty()!
	console.print_header(' zinit destroyed')
}

pub fn start() ! {
	console.print_header(' zinit start')
	initd_proc_get(delete: true, start: true)!
}
