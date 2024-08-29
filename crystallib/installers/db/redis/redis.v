module redis

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.sysadmin.startupmanager
import time
import os

@[params]
pub struct InstallArgs {
pub mut:
	port    int    = 6379
	datadir string = '${os.home_dir()}/hero/var/redis'
	ipaddr  string = 'localhost' // can be more than 1, space separated
	reset   bool
	start   bool
	restart bool = true
}

// ```
// struct InstallArgs {
// 	port    int    = 6379
// 	datadir string = '${os.home_dir()}/hero/var/redis'
// 	ipaddr  string = "localhost" //can be more than 1, space separated
// 	reset   bool
// 	start   bool
// 	restart bool = true
// }
// ```
pub fn install(args_ InstallArgs) ! {
	mut args := args_

	console.print_header('install redis.')

	if !(osal.cmd_exists_profile('redis-server')) {
		if osal.is_linux() {
			osal.package_install('redis-server')!
		} else {
			osal.package_install('redis')!
		}
	}
	osal.execute_silent('mkdir -p ${args.datadir}')!

	if args.restart {
		stop()!
	}
	start(args)!
}

fn configfilepath(args InstallArgs) string {
	if osal.is_linux() {
		return '/etc/redis/redis.conf'
	} else {
		return '${args.datadir}/redis.conf'
	}
}

fn configure(args InstallArgs) ! {
	c := $tmpl('template/redis_config.conf')
	pathlib.template_write(c, configfilepath(), true)!
}

pub fn check(args InstallArgs) bool {
	res := os.execute('redis-cli -c -p ${args.port} ping > /dev/null 2>&1')
	console.print_debug('redis ping ok.')
	if res.exit_code == 0 {
		return true
	}
	return false
}

pub fn start(args InstallArgs) ! {
	if check() {
		return
	}

	configure(args)!
	// remove all redis in memory
	osal.process_kill_recursive(name: 'redis-server')!

	mut sm := startupmanager.get()!
	sm.start(
		name: 'redis'
		cmd: 'redis-server ${configfilepath()} --daemonize yes'
	)!

	for _ in 0 .. 100 {
		if check() {
			console.print_debug('redis started.')
			return
		}
		time.sleep(100)
	}
	return error("Redis did not install propertly could not do:'redis-cli -c ping'")
}

pub fn stop() ! {
	osal.execute_silent('redis-cli shutdown')!
}
