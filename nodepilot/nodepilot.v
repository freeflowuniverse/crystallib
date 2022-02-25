module nodepilot

import freeflowuniverse.crystallib.builder

struct NodePilot {
mut:
	node builder.Node
}

pub fn nodepilot_new(name string, ipaddr string) ? NodePilot {
	node := builder.node_new(name: name, ipaddr: ipaddr)?
	return NodePilot{node: node}
}

pub fn (mut n NodePilot) prepare() ? {
	if ! n.node.cmd_exists("git") {
		n.node.package_install(name: "git")?
	}

	if ! n.node.cmd_exists("docker") {
		n.node.package_install(name: "docker.io")?
	}
}
