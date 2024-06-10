module screen

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import os
import time

pub fn testsuite_begin() ! {
	mut screen_factory := new(reset:true)!
}

pub fn test_screen_status() ! {
	mut screen_factory := new()!
	mut screen := screen_factory.add(name: 'testservice', cmd: 'redis-server')!
	status := screen.status()!
	println('debugzos ${status}')
	// assert status == .active
}