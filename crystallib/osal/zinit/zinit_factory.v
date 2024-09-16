module zinit

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal

__global (
	zinit_global shared map[string]&Zinit
)

pub fn new() !&Zinit {
	name := 'default'
	rlock zinit_global {
		if name !in zinit_global {
			set()!
		}
		return zinit_global[name] or { panic('bug') }
	}
	return error("cann't find zinit in globals:'${name}'")
}

fn set() ! {
	name := 'default'
	mut self := Zinit{
		path: pathlib.get_dir(path: '/etc/zinit', create: true)!
		pathcmds: pathlib.get_dir(path: '/etc/zinit/cmds', create: true)!
		pathtests: pathlib.get_dir(path: '/etc/zinit/tests', create: true)!
	}
	self.load()!
	lock zinit_global {
		zinit_global[name] = &self
	}
}

pub fn check() bool {
	if !osal.cmd_exists('zinit') {
		return false
	}
	// println(osal.execute_ok('zinit list'))
	return osal.execute_ok('zinit list')
}

// remove all know services to zinit
pub fn destroy() ! {
	initd_proc_get(delete: true, start: false)!
	mut zinitpath := pathlib.get_dir(path: '/etc/zinit', create: true)!
	zinitpath.empty()!
	console.print_header(' zinit destroyed')
}
