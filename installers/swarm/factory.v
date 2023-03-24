module swarm

import freeflowuniverse.crystallib.builder

enum State {
	ok
	error
	reset
}

struct Installer {
mut:
	node  &builder.Node
	state State
}

pub fn get(mut node builder.Node) Installer {
	mut i := Installer{
		node: &node
	}
	return i
}

// pub fn install() !Installer {
// 	mut builder := builder.new()
// 	mut node := builder.node_local()!
// 	mut i := get(mut node)
// 	i.docker.install()!
// 	return i
// }
