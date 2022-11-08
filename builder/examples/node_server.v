module main

import freeflowuniverse.crystallib.builder { NodeArguments }

fn do() ! {
	mut builder := builder.new()

	node_args := NodeArguments{
		ipaddr: '185.206.122.152:22'
		name: 'VMa05bdc33'
	}

	mut node := builder.node_new(node_args) or { return error('Failed to create node: $err') }

	println(node)
}

fn main() {
	do() or { panic(err) }
}
