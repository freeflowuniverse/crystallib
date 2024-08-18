module ufw

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os
import time
import json

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
	restart bool = true
	rules []Rule
	ssh bool = true //leave this on, its your backdoor to get in the system
}


// install ufw will return true if it was already installed
pub fn install(args_ InstallArgs) ! {
	mut args := args_

	console.print_header('install ufw.')
	if !osal.is_linux() {
		return error("only linux supported")
	}
	if !(osal.cmd_exists('ufw')) {		
		osal.package_install('ufw')!		
	}

	if args.reset{
		reset()!
	}
	if args.restart{
		restart()!
	}	
	console.print_debug('install ufw ok')
}

pub fn restart() ! {
	stop()!
	start()!
}

pub fn stop() ! {
	name := 'ufw'
	console.print_debug('stop ufw')
	osal.execute_silent("
		ufw --force disable
		systemctl stop ufw
		")!
}

pub fn start(args InstallArgs) ! {
	console.print_debug('start ufw')
	osal.execute_silent("
		systemctl start ufw
		ufw enable
		")!
}

pub fn check() bool {

	return false
}


pub fn configure(args InstallArgs) ! {
	console.print_debug('configure ufw')
	osal.exec(cmd:"
		ufw disable
		")!
		
	ufw allow from 2001:db8::1 to any port 80 proto tcp


	if args.ssh{
		osal.exec(cmd:"ufw allow 22")!
	}
	osal.exec(cmd:"ufw --force enable")!
}

