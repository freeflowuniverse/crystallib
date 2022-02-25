module nodepilot

import freeflowuniverse.crystallib.builder

struct NodePilot {
	noderoot string
	repository string
mut:
	node builder.Node
}

pub fn nodepilot_new(name string, ipaddr string) ? NodePilot {
	node := builder.node_new(name: name, ipaddr: ipaddr)?
	return NodePilot{
		node: node,
		noderoot: "/root/node-pilot-light",
		repository: "https://github.com/threefoldtech/node-pilot-light"
	}
}

pub fn (mut n NodePilot) prepare() ? {
	if ! n.node.cmd_exists("git") {
		n.node.package_install(name: "git")?
	}

	if ! n.node.cmd_exists("docker") {
		n.node.package_install(name: "ca-certificates curl gnupg lsb-release")?
		n.node.executor.exec("curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg")?

		arch := n.node.executor.exec("dpkg --print-architecture")?.trim_space()
		release := n.node.executor.exec("lsb_release -cs")?.trim_space()

		n.node.executor.exec('echo "deb [arch=$arch signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $release stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null')?

		n.node.package_refresh()?
		n.node.package_install(name: "docker-ce docker-ce-cli containerd.io")?
		n.node.executor.exec("service docker start")?
	}

	n.node.executor.exec("docker ps -a")?

	if ! n.node.executor.dir_exists(n.noderoot) {
		// FIXME: repository is private
		n.node.executor.exec("git clone $n.repository $n.noderoot")?
	}
}
