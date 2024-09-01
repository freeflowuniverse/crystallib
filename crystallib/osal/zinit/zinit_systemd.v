module zinit

import freeflowuniverse.crystallib.osal.systemd
import freeflowuniverse.crystallib.ui.console


pub fn (mut self Zinit) systemd_start() ! {
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
