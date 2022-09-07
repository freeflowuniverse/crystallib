module mdbook

import builder

enum State {
	ok
	error
	reset
}

struct Installer {
	node  &builder.Node
	state State
}

// install mdbook will return true if it was already installed
pub fn get(mut node builder.Node) ?Installer {
	mut i := Installer{
		node: &node
	}
	return i
}

pub fn install() ?Installer {
	mut builder := builder.new()
	mut node := builder.node_local()?
	mut i := get(mut node)?
	i.install()?
	return i
}

