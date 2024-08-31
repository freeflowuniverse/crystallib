module zinit

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.ui.console
import time

pub struct ZProcess {
pub:
	name string = "default"
pub mut:
	cmd     string		//command to start
	test    string 		//command line to test service is running
	status  ZProcessStatus
	pid     int
	after   []string 	//list of service we depend on
	env     map[string]string
	oneshot bool
}

pub enum ZProcessStatus {
	unknown
	init
	ok
	killed
	error
	blocked
	spawned
}

pub fn (mut zinit Zinit) get(name_ string) !ZProcess {
	name := texttools.name_fix(name_)
	// console.print_debug(zinit)
	return zinit.processes[name] or { return error("cannot find process in zinit:'${name}'") }
}

pub fn (mut zinit Zinit) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	if name in zinit.processes {
		return true
	}
	return false
}

@[params]
pub struct ZProcessNewArgs {
pub mut:
	name      string            @[required]
	cmd       string            @[required]
	cmd_file  bool // if we wanna force to run it as a file which is given to bash -c  (not just a cmd in zinit)
	test      string
	test_file bool
	after     []string
	env       map[string]string
	oneshot   bool
	start 	  bool = true
}

//will delete the process if it exists while starting
pub fn (mut zinit Zinit) new(args_ ZProcessNewArgs) !ZProcess {
	mut args := args_

	args.name = texttools.name_fix(args.name)

	console.print_header(' zinit process new: ${args.name}')

	if args.cmd.len == 0 {
		$if debug {
			print_backtrace()
		}
		return error('cmd cannot be empty for ${args} in zinit.')
	}

	if zinit.exists(args.name) {
		mut p := zinit.get(args.name)!
		p.destroy()!
	}

	mut zp := ZProcess{
		name: args.name
		cmd: args.cmd
	}

	// means we can load the special cmd
	mut pathcmd := zinit.pathcmds.file_get_new(args.name + '.sh')!

	zp.cmd = 'echo === START ======== ${ourtime.now().str()} === \n' + texttools.dedent(zp.cmd) + "\n"
	pathcmd.write(zp.cmd)!
	pathcmd.chmod(0x770)!
	zp.cmd = '/bin/bash -c ${pathcmd.path}'

	if args.test.len > 0 {
		if args.test.contains('\n') || args.test_file {
			// means we can load the special cmd
			mut pathcmd2 := zinit.pathtests.file_get_new(args.name + '.sh')!
			args.test = texttools.dedent(args.test)
			pathcmd2.write(args.test)!
			pathcmd2.chmod(0x770)!
			zp.test = '/bin/bash -c ${pathcmd2.path}'
		}
	}

	zp.oneshot = args.oneshot
	zp.env = args.env.move()
	zp.after = args.after
	mut pathyaml := zinit.path.file_get_new(zp.name + '.yaml')!
	// console.print_debug('debug zprocess path yaml: ${pathyaml}')
	pathyaml.write(zp.config_content())!
	if args.start{
		zp.start()!
	}
	zinit.processes[args.name] = zp

	return zp
}

pub fn (mut zinit Zinit) stop(name string) ! {
	mut p:=zinit.get(name)!
	p.stop()!
}

pub fn (mut zinit Zinit) start(name string) ! {
	mut p:=zinit.get(name)!
	p.start()!
}

pub fn (mut zinit Zinit) delete(name string) ! {
	mut p:=zinit.get(name)!
	p.destroy()!
}


pub fn (zp ZProcess) cmd() string {
	p := '/etc/zinit/cmd/${zp.name}.sh'
	if os.exists(p) {
		return "bash -c \"${p}\""
	} else {
		if zp.cmd.contains('\n') {
			panic('cmd cannot have \\n and not have cmd file on disk on ${p}')
		}
		if zp.cmd == '' {
			panic('cmd cannot be empty')
		}
	}
	return '${zp.cmd}'
}

pub fn (zp ZProcess) cmdtest() string {
	p := '/etc/zinit/tests/${zp.name}.sh'
	if os.exists(p) {
		return "bash -c \"${p}\""
	} else {
		if zp.test.contains('\n') {
			panic('cmd cannot have \\n and not have cmd file on disk on ${p}')
		}
		if zp.test == '' {
			panic('cmd cannot be empty')
		}
	}
	return '${zp.test}'
}

// return the configuration as needs to be given to zinit
fn (zp ZProcess) config_content() string {
	mut out := "
exec: \"${zp.cmd()}\"
signal:
  stop: SIGKILL
log: ring
"
	if zp.test.len > 0 {
		out += "test: \"${zp.cmdtest()}\"\n"
	}
	if zp.oneshot {
		out += 'oneshot: true\n'
	}
	if zp.after.len > 0 {
		out += 'after:\n'
		for val in zp.after {
			out += '  - ${val}\n'
		}
	}
	if zp.env.len > 0 {
		out += 'env:\n'
		for key, val in zp.env {
			out += '  ${key}: \'${val}\'\n'
		}
	}
	return out
}

pub fn (zp ZProcess) start() ! {
	console.print_header(' start ${zp.name}')
	mut client := new_rpc_client()
	if !client.isloaded(zp.name) {
		client.monitor(zp.name)! // means will check it out
	}
}

pub fn (mut zp ZProcess) stop() ! {
	console.print_header(' stop ${zp.name}')
	st := zp.status()!
	if st in [.unknown, .error, .killed] {
		return
	}
	mut client := new_rpc_client()
	client.stop(zp.name)!
	zp.status()!
}

pub fn (mut zp ZProcess) destroy() ! {
	console.print_header(' destroy ${zp.name}')
	zp.stop()!
	mut client := new_rpc_client()
	client.forget(zp.name) or {}
	mut zinit := get()!
	mut path1 := zinit.pathcmds.file_get_new(zp.name + '.sh')!
	mut path2 := zinit.pathtests.file_get_new(zp.name + '.sh')!
	mut pathyaml := zinit.path.file_get_new(zp.name + '.yaml')!
	path1.delete()!
	path2.delete()!
	pathyaml.delete()!
}

// how long to wait till the specified output shows up, timeout in sec
pub fn (mut zp ZProcess) output_wait(c_ string, timeoutsec int) ! {
	zp.start()!
	_ = new_rpc_client()
	zp.check()!
	mut t := ourtime.now()
	start := t.unix()
	c := c_.replace('\n', '')
	for _ in 0 .. 2000 {
		o := zp.log()!
		console.print_debug(o)
		$if debug {
			console.print_debug(" - zinit ${zp.name}: wait for: '${c}'")
		}
		// need to replace \n because can be wrapped because of size of pane
		if o.replace('\n', '').contains(c) {
			return
		}
		mut t2 := ourtime.now()
		if t2.unix() > start + timeoutsec {
			return error('timeout on output wait for zinit.\n${zp.name} .\nwaiting for:\n${c}')
		}
		time.sleep(100 * time.millisecond)
	}
}

// check if process is running if yes return the log
pub fn (zp ZProcess) log() !string {
	assert zp.name.len > 2
	cmd := 'zinit log ${zp.name} -s'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		$if debug {
			print_backtrace()
		}
		return error('zprocesslog: could not execute ${cmd}')
	}
	mut out := []string{}

	for line in res.output.split_into_lines() {
		if line.contains('=== START ========') {
			out = []string{}
		}
		out << line
	}

	return out.join_lines()
}

// return status of process
//```
// enum ZProcessStatus {
// 	unknown
// 	init
// 	ok
// 	error
// 	blocked
// 	spawned
// killed
// }
//```
pub fn (mut zp ZProcess) status() !ZProcessStatus {
	cmd := 'zinit status ${zp.name}'
	r := osal.execute_silent(cmd)!
	for line in r.split_into_lines() {
		if line.starts_with('pid') {
			zp.pid = line.split('pid:')[1].trim_space().int()
		}
		if line.starts_with('state') {
			st := line.split('state:')[1].trim_space().to_lower()
			// console.print_debug(" status string: $st")	
			if st.contains('sigkill') {
				zp.status = .killed
			} else if st.contains('error') {
				zp.status = .error
			} else if st.contains('spawned') {
				zp.status = .error
			} else if st.contains('running') {
				zp.status = .ok
			} else {
				zp.status = .unknown
			}
		}
	}
	// mut client := new_rpc_client()
	// st := client.status(zp.name) or {return .unknown}
	// statusstr:=st.state.to_lower()
	// if statusstr=="running"{
	// 	zp.status = .ok
	// }else if statusstr.contains("error"){
	// 	zp.status = .error
	// }else{
	// 	console.print_debug(st)
	// 	panic("status not implemented yet")
	// }
	return zp.status
}

// will check that process is running
pub fn (mut zp ZProcess) check() ! {
	status := zp.status()!
	if status != .ok {
		return error('process is not running.\n${zp}')
	}
}

// will check that process is running
pub fn (mut zp ZProcess) isrunning() !bool {
	status := zp.status()!
	if status != .ok {
		return false
	}
	return true
}
