module startupmanager

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.osal.systemd

const process_name = 'testprocess'

pub fn testsuite_begin() ! {
	mut sm := get()!
	if sm.exists(startupmanager.process_name)! {
		sm.stop(startupmanager.process_name)!
	}
}

pub fn testsuite_end() ! {
	mut sm := get()!
	if sm.exists(startupmanager.process_name)! {
		sm.stop(startupmanager.process_name)!
	}
}

// remove from the startup manager
pub fn test_status() ! {
	mut sm := get()!

	sm.start(
		name: startupmanager.process_name
		cmd: 'redis-server'
	)!

	status := sm.status(startupmanager.process_name)!
	assert status == .active
}
