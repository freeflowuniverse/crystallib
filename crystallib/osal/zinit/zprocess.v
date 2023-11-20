module zinit

import os
import freeflowuniverse.crystallib.core.texttools

pub struct ZProcess {
pub:
	name string
pub mut:
	cmd     string
	test    string
	status  ZProcessStatus
	pid     int
	after   []string
	env     map[string]string
	oneshot bool
	zinit   &Zinit            [skip; str: skip]
}

pub enum ZProcessStatus {
	unknown
	init
	ok
	error
	blocked
	spawned
}

pub fn (mut zinit Zinit) process_new(args_ ZProcessNewArgs) !ZProcess {
	mut args := args_

	println(' - zinit new: ${args.name}')

	mut zp := ZProcess{
		name: args.name
		zinit: &zinit
	}

	if args.cmd.len == 0 {
		return error('cmd cannot be empty for ${args} in zinit.')
	}

	if args.cmd.contains('\n') || args.cmd_file {
		// means we can load the special cmd
		mut pathcmd := zinit.pathcmds.file_get_new(args.name + '.sh')!
		args.cmd = texttools.dedent(args.cmd)
		pathcmd.write(args.cmd)!
		pathcmd.chmod(0x770)!
		zp.cmd = '/bin/bash -c ${pathcmd.path}'
	}

	if args.test.len > 0 {
		if args.test.contains('\n') || args.test_file {
			// means we can load the special cmd
			mut pathcmd := zinit.pathtests.file_get_new(args.name + '.sh')!
			args.test = texttools.dedent(args.test)
			pathcmd.write(args.test)!
			pathcmd.chmod(0x770)!
			zp.test = '/bin/bash -c ${pathcmd.path}'
		}
	}

	zp.oneshot = args.oneshot
	zp.env = args.env.move()
	zp.after = args.after
	mut pathyaml := zinit.path.file_get_new(zp.name + '.yaml')!
	println('debugzo: ${pathyaml}')
	pathyaml.write(zp.config_content())!

	zinit.processes[args.name] = zp

	return zp
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
			out += '  ${key}:${val}\n'
		}
	}
	return out
}

pub fn (zp ZProcess) start() ! {
	mut client := new_rpc_client()
	if !client.isloaded(zp.name) {
		client.monitor(zp.name)! // means will check it out
	}
	// st := client.status
	// println(st)
	// if true{panic("SS")}		
	// client.start(zp.name)!
}

pub fn (zp ZProcess) stop() ! {
	mut client := new_rpc_client()
	st := client.status(zp.name)!

	client.stop(zp.name)!
}
