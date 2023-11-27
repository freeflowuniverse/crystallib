module initd

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
// function initdinstall {
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
pub struct Initd {
pub mut:
	processes map[string]IProcess
	path      pathlib.Path
}

pub fn new() !Initd {
	mut initdobj := Initd{
		path: pathlib.get_dir(path: '/etc/systemd/system', create: false)!
	}
	initdobj.load()!
	return initdobj
}

fn (mut initdobj Initd) load() ! {
	cmd := 'systemctl list-units --type=service'
	r := osal.execute_silent(cmd)!
	for mut line in r.split_into_lines() {
		if line.starts_with('---') {
			continue
		}
		if line.contains('UNIT') {
			continue
		}
		if line.contains('LOAD') {
			break
		}
		line = line.trim(' ')
		if line == '' {
			continue
		}
		for {
			if line.contains('  ') {
				line = line.replace('  ', ' ')
			} else {
				break
			}
		}

		items := line.split_nth(' ', 5)
		mut pobj := IProcess{
			name: items[0]
			description: items[4]
			initd: &initdobj
		}
		pobj.name = pobj.name.replace('.service', '')
		status := items[3]
		if status == 'exited' {
			pobj.status = .exited
		} else if status == 'running' {
			pobj.status = .running
		} else {
			return error("Can't find right status: ${status}")
		}
		name := texttools.name_fix(items[0])
		initdobj.processes[name] = pobj
	}
}

@[params]
pub struct IProcessNewArgs {
pub mut:
	name        string @[required]
	cmd         string @[required]
	description string @[required]
	// env       map[string]string
}

//```
// name      string            @[required]
// cmd       string            @[required]
// description string @[required]
//```
pub fn (mut initd Initd) new(args_ IProcessNewArgs) !IProcess {
	mut args := args_

	mut zp := IProcess{
		name: args.name
		description: args.description
		cmd: args.cmd
		initd: &initd
	}

	if args.cmd.contains('\n') {
		// means we can load the special cmd
		mut pathcmd := initd.path.file_get(args.name)!
		pathcmd.write(zp.cmd)!
		zp.cmd = '/bin/bash -c ${pathcmd.path}'
	}
	// zp.env = args.env.move()

	initd.processes[args.name] = zp

	return zp
}

pub fn (mut initd Initd) get(name_ string) !IProcess {
	name := texttools.name_fix(name_)
	if name in initd.processes {
		return initd.processes[name]
	}
	return error("Can't find process with name ${name}")
}

pub fn (mut initd Initd) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	if name in initd.processes {
		return true
	}
	return false
}
