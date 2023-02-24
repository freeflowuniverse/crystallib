module main

import freeflowuniverse.crystallib.builder { NodeArguments }

fn do() ! {
	mut builder := builder.new()

	node_args := NodeArguments{
		ipaddr: '195.192.213.4:22'
		name: 'VMa05bdc33'
	}

	mut node := builder.node_new(node_args) or { return error('Failed to get node: ${err}') }

	res:=node.exec("ls /")!

	println(node)
	println(res)
}

fn main() {
	do() or { panic(err) }
}
