module systemd

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import json
import os
import freeflowuniverse.crystallib.clients.redisclient

// function systemdinstall {
//     set -x
//     if [[ "$OSTYPE" == "linux-gnu"* ]]; then     
//         local script_name="$1"
//         local cmd="$2"            
//         servicefile="

//         spath="/etc/systemd/system/${script_name}.service"
//         rm -f $spath
//         echo "$servicefile" > $spath
//         systemctl daemon-reload
//         systemctl enable $script_name
//         systemctl start $script_name
//     fi
// }

@[heap]
pub struct Systemd {
pub mut:
	processes []&SystemdProcess
	path      pathlib.Path
	path_cmd  pathlib.Path
}

pub fn new() !Systemd {
	mut systemdobj := Systemd{
		path: pathlib.get_dir(path: '/etc/systemd/system', create: false)!
		path_cmd: pathlib.get_dir(path: '/etc/systemd_cmds', create: true)!
	}
	systemdobj.load()!
	return systemdobj
}

fn (mut systemdobj Systemd) load() ! {
	console.print_header('Systemd load')
	systemdobj.processes=[]&SystemdProcess{}
	mut redis := redisclient.core_get()!

	for item in process_list()!{
		mut sdprocess:=SystemdProcess{
			description:item.description
			systemdobj:&systemdobj
			unit:item.unit
			info:item
		}
		name:=sdprocess.unit
		key:="systemd:${name}"		
		if redis.exists(key)!{
			mut sdprocess_redis:=systemdobj.get(name)!
			sdprocess_redis.info = sdprocess.info
			sdprocess_redis.description = sdprocess.description
			systemdobj.set(mut sdprocess_redis)!
		}else{
			systemdobj.set(mut sdprocess)!
		}

		
	}
}

@[params]
pub struct SystemdProcessNewArgs {
pub mut:
	name        string @[required]
	cmd         string @[required]
	description string
	// env       map[string]string
}

//```
// name      string            @[required]
// cmd       string            @[required]
// description string @[required]
//```
pub fn (mut systemdobj Systemd) new(args_ SystemdProcessNewArgs) !SystemdProcess {
	mut args := args_
	if !(args.name.ends_with(".service")){
		args.name="${args.name}.service"
	}

	mut sdprocess := SystemdProcess{
		name: args.name
		description: args.description
		cmd: args.cmd
		systemdobj: &systemdobj
	}

	if args.cmd.contains('\n') {
		// means we can load the special cmd
		mut pathcmd := systemdobj.path_cmd.file_get(args.name)!
		pathcmd.write(sdprocess.cmd)!
		sdprocess.cmd = '/bin/bash -c ${pathcmd.path}'
	}
	// sdprocess.env = args.env.move()

	systemdobj.set(mut sdprocess)!

	sdprocess.start()!

	return sdprocess
}

pub fn (mut systemdobj Systemd) names() []string {
	r:=systemdobj.processes.map(it.name)
	return r
}


pub fn (mut systemdobj Systemd) set(mut sdprocess SystemdProcess) ! {

	unit_ := texttools.name_fix(sdprocess.info.unit)

	if sdprocess.name==""{
		sdprocess.name = unit_
	}else{
		sdprocess.name = texttools.name_fix(sdprocess.name)
	}
	systemdobj.set_internal(mut sdprocess)!
	systemdobj.set_redis(mut sdprocess)!
}


fn (mut systemdobj Systemd) set_internal(mut sdprocess SystemdProcess) ! {
	systemdobj.processes=systemdobj.processes.filter(it.name!=sdprocess.name)
	systemdobj.processes << &sdprocess
}

fn (mut systemdobj Systemd) set_redis(mut sdprocess SystemdProcess) ! {
	mut redis := redisclient.core_get()!
	key:="systemd:${sdprocess.name}"
	data := json.encode(sdprocess)
	redis.set(key,data)!
}


pub fn (mut systemdobj Systemd) get(name string) !&SystemdProcess {
	// name := texttools.name_fix(name_)
	mut redis := redisclient.core_get()!
	key:="systemd:${name}"
	mut sdprocess:=SystemdProcess{
		systemdobj: &systemdobj		
	}
	if redis.exists(key)!{
		data:=redis.get(key)!
		sdprocess=json.decode(SystemdProcess,data)!
		sdprocess.systemdobj = &systemdobj
		return &sdprocess
	}
	return error("Can't find systemd process with name ${name}, maybe reload the state with systemd.load()")
}

pub fn (mut systemdobj Systemd) exists(name string) bool {
	for item in systemdobj.processes{
		if item.name == name{
			return true
		}
	}
	return false
}
