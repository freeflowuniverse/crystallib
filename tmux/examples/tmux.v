module main

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.tmux

fn do() ! {
	mut builder := builder.new()

	// create local and remote nodes
	mut node_local := builder.node_local()!
	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!

	// install tmux to nodes
	installer := tmux.get_install(mut node_ssh) or {
		return error('could not install tmux to node: $err')
	}

	// print node info
	println(node_local)
	println(node_ssh)
}

fn main() {
	do() or { panic(err) }
}
