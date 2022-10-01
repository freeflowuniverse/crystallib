module repository

import freeflowuniverse.crystallib.builder

enum State {
	ok
	error
	reset
}

struct Installer {
	node  &builder.Node
	state State
}

// install repository will return true if it was already installed
pub fn get(mut node builder.Node) ?Installer {
	mut i := Installer{
		node: &node
	}
	return i
}

pub fn get_install(mut node builder.Node, repo_url string) ?Installer {
	mut i := Installer{
		node: &node
	}
	i.install(repo_url)?
	return i
}

pub fn install(repo_url string) ?Installer {
	mut builder := builder.new()
	mut node := builder.node_local()?
	mut i := get(mut node)?
	i.install(repo_url)?
	return i
}
