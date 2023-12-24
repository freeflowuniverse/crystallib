module python

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

pub fn install() ! {
	if !osal.done_exists('install_python') && !osal.cmd_exists('python') {
		base.install()!
		println(' - package install install python')
		osal.package_install('python3')!
		// cmd := '
		// '
		// osal.execute_silent(cmd)!
		osal.done_set('install_python', 'OK')!
	}
	// println(' - python already done')
}

pub fn check() ! {
	// todo: do a monitoring check to see if it works
	// cmd := '
	// '
	// r := osal.execute_silent(cmd)!
	// println(r)
}
