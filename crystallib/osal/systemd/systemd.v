module systemd

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console

// import freeflowuniverse.crystallib.clients.redisclient

@[heap]
pub struct Systemd {
pub mut:
	processes []&SystemdProcess
	path      pathlib.Path
	path_cmd  pathlib.Path
}

pub fn new() !Systemd {
	mut systemd := Systemd{
		path: pathlib.get_dir(path: '/etc/systemd/system', create: false)!
		path_cmd: pathlib.get_dir(path: '/etc/systemd_cmds', create: true)!
	}
	systemd.load()!
	return systemd
}

// check if systemd is on system, returns True if yes
pub fn check() !bool {
	if !osal.cmd_exists('systemctl') {
		return false
	}

	return osal.execute_ok('systemctl status --no-pager')
}

fn (mut systemd Systemd) load() ! {
	console.print_header('Systemd load')
	systemd.processes = []&SystemdProcess{}
	for item in process_list()! {
		mut sdprocess := SystemdProcess{
			description: item.description
			systemd: &systemd
			unit: item.unit
			info: item
		}
		systemd.setinternal(mut sdprocess)!
	}
}

@[params]
pub struct SystemdProcessNewArgs {
pub mut:
	name        string            @[required]
	cmd         string            @[required]
	description string
	env         map[string]string
	start       bool = true
}

//```
// name      string            @[required]
// cmd       string            @[required]
// description string @[required]
//```
pub fn (mut systemd Systemd) new(args_ SystemdProcessNewArgs) !SystemdProcess {
	mut args := args_
	args.name = name_fix(args.name)

	mut sdprocess := SystemdProcess{
		name: args.name
		description: args.description
		cmd: args.cmd
		systemd: &systemd
		info: SystemdProcessInfo{
			unit: args.name
		}
	}

	if args.cmd.contains('\n') {
		// means we can load the special cmd
		mut pathcmd := systemd.path_cmd.file_get('${args.name}_cmd')!
		pathcmd.write(sdprocess.cmd)!
		sdprocess.cmd = '/bin/bash -c ${pathcmd.path}'
	}
	sdprocess.env = args.env.move()

	systemd.setinternal(mut sdprocess)!

	sdprocess.write()!

	if args.start {
		sdprocess.start()!
	}

	return sdprocess
}

pub fn (mut systemd Systemd) names() []string {
	r := systemd.processes.map(it.name)
	return r
}

fn (mut systemd Systemd) setinternal(mut sdprocess SystemdProcess) ! {
	sdprocess.name = name_fix(sdprocess.info.unit)
	systemd.processes = systemd.processes.filter(it.name != sdprocess.name)
	systemd.processes << &sdprocess
}

pub fn (mut systemd Systemd) get(name_ string) !&SystemdProcess {
	name := name_fix(name_)
	if systemd.processes.len == 0 {
		systemd.load()!
	}
	for item in systemd.processes {
		if item.name == name {
			return item
		}
	}
	return error("Can't find systemd process with name ${name}, maybe reload the state with systemd.load()")
}

pub fn (mut systemd Systemd) exists(name_ string) bool {
	name := name_fix(name_)
	for item in systemd.processes {
		if item.name == name {
			return true
		}
	}
	return false
}

fn name_fix(name_ string) string {
	mut name := texttools.name_fix(name_)
	if name.contains('.service') {
		name = name.all_before_last('.')
	}
	return name
}
