module builder

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct ThisRemoteArgs {
pub mut:
	name            string = 'remote'
	nodes           string
	script          string
	sync_from_local bool
}

// to use do something like: export NODES="195.192.213.3" .
pub fn this_remote_exec(args_ ThisRemoteArgs) !bool {
	mut args := args_
	if args.script.trim_space().starts_with('/tmp/remote_') {
		return false // means we need to execute
	}
	addr := texttools.to_array(args.nodes)
	// console.print_debug(addr)
	mut counter := 0
	for a in addr {
		counter += 1
		name := '${args.name}_${counter}'
		mut b := new()!
		if args.sync_from_local {
			mut n := b.node_new(ipaddr: a, name: name)!
			// console.print_debug(n.ipaddr_pub_get()!)
			n.vscript(path: args.script, sync_from_local: args.sync_from_local)!
		} else {
			// is a shortcut goes faster if no update
			if !os.exists(args.script) {
				return error("can't find script ${args.script}")
			}
			cmd := 'scp ${args.script} ${a}:/tmp/remote_${name}.vsh'
			console.print_debug(cmd)
			r := os.execute(cmd)
			if r.exit_code > 0 {
				return error('could not scp: ${cmd}')
			}
			// cmd:="scp ${args.script} ${a}:/tmp/remote_${name}.vsh"
			cmd2 := "ssh ${a} 'v -w -enable-globals /tmp/remote_${name}.vsh'"
			osal.exec(cmd: cmd2, stdout: true)!
		}
	}
	return true
}
