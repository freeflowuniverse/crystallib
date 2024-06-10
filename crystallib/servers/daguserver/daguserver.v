module daguserver

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.dagu
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.sysadmin.startupmanager


pub fn (mut self DaguServer[Config]) dag_path(name string) string {
	return '${os.home_dir()}/dags/${texttools.name_fix(name)}.yaml'
}

pub fn (mut self DaguServer[Config]) is_running() !bool {
	mut sm := startupmanager.get()!
	if sm.status('dagu_${self.instance}')! == .active {
		return true
	}
	return false
}

pub fn (mut self DaguServer[Config]) start() ! {
	mut cfg := self.config()!


	mut sm := startupmanager.get()!

	// TODO: we are not taking host into consideration (port is in configpath)
	cmd := 'dagu server --host 0.0.0.0 --config ${cfg.configpath}'

	sm.start(
		name: 'dagu_${self.instance}'
		cmd: cmd
		env: {
			'HOME': '/root'
		}
	)!
}

// Display current status of the DAG
pub fn (mut self DaguServer[Config]) status() !startupmanager.ProcessStatus {
	mut sm := startupmanager.get()!
	return sm.status('dagu_${self.instance}')!
}

pub fn (mut self DaguServer[Config]) restart() ! {
	self.stop()!
	self.start()!
}

pub fn (mut self DaguServer[Config]) stop() ! {
	console.print_header('dagu stop')
	mut sm := startupmanager.get()!
	sm.stop('dagu_${self.instance}')!
}