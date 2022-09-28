module main

import freeflowuniverse.crystallib.builder

fn do() ? {
	mut builder := builder.new()

	// pub struct NodeArguments {
	// 	ipaddr string
	// 	name   string
	// 	user   string = "root"
	// 	debug  bool
	// 	reset bool
	//	redisclient &redisclient.Redis
	// 	}
	//```
	mut node := builder.node_new(name:"test",ipaddr:"185.206.122.153")?

	res := node.exec("ls /")?
	println(res)
}

fn main() {
	do() or { panic(err) }
}
