module daguserver

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.daguclient
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.core.texttools

const instance_name = 'testinstance'

pub fn testsuite_begin() ! {
	cleanup()!
}

pub fn testsuite_end() ! {
	cleanup()!
}

fn cleanup() ! {
	mut sm := startupmanager.get()!
	if sm.exists('${instance_name}_dagu')! {
		sm.stop('${instance_name}_dagu')!
	}
}

pub fn test_is_running() ! {
	mut server := get(instance_name)!
	assert !server.is_running()!
	server.start()!
	assert server.is_running()!
	server.stop()!
	assert !server.is_running()!
}
