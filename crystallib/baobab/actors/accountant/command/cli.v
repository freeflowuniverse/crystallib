module main

import os
import cli { Command }
import vweb
import freeflowuniverse.crystallib.baobab.actors.accountant
import freeflowuniverse.crystallib.rpc.openrpc
import freeflowuniverse.crystallib.core.pathlib

const (
    openrpc_path = '${os.dir(os.dir(@FILE))}/openrpc.json'
    playground_path = '${os.dir(os.dir(@FILE))}/playground'
)

fn do() ! {
	mut cmd := Command{
		name: 'accountant'
		description: 'Your accountant toolset.'
		version: '1.0.16'
	}


	mut cmd_run := Command{
		name: 'run_server'
		description: 'Run accountant websocket server.'
		usage: ''
		required_args: 0
		execute: cmd_run_wsserver
	}

	mut cmd_playground := Command{
		name: 'playground'
		description: 'Run accountant playground server.'
		usage: ''
		required_args: 0
		execute: playground
	}

	cmd.add_command(cmd_run)
	cmd.add_command(cmd_playground)
	cmd.setup()
	cmd.parse(os.args)

	
}

fn cmd_run_wsserver(cmd Command) ! {
	accountant.run_wsserver(3000)!
}

fn playground(cmd Command) ! {
    pg := openrpc.new_playground(
	    dest: pathlib.get_dir(path: playground_path)!
	    specs: [pathlib.get_file(path:openrpc_path)!]
    )!
    vweb.run(pg, 8080)
}


fn main() {
	do() or { panic(err) }
}
