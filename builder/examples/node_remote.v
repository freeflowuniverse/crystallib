module main

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.installers.vlang
import freeflowuniverse.crystallib.installers.caddy

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
	mut node := builder.node_new(name:"test", ipaddr:"185.206.122.151", debug:true)?

	res := node.exec("ls /")?
	println(res)

	ssh_dir := node.exec("cd .ssh")?
	println(ssh_dir)
}

fn main() {
	do() or { panic(err) }
}
