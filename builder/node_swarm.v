

module builder


pub struct SwarmArgs{
	reset bool
}

//installs docker & swarm
fn (mut node Node) swarm_prepare(args SwarmArgs) ?{
	node.platform_prepare()?
	was_done := node.crystaltools_install()?
	if was_done{
		node.crystaltools_update(reset:args.reset)?
	}

	docker_install := '
		set -ex
		apt update
		apt upgrade -y
		apt autoremove -y
		apt install apt-transport-https ca-certificates curl software-properties-common -y
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		#THIS IS FOR UBUNTU 20.04 (focal)
		add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
		apt update
		apt install docker-ce -y
		systemctl start docker
		systemctl enable docker
		'

	node.exec(cmd:docker_install,reset:args.reset)?

	// >TODO: check that the ubuntu is focal

}

pub fn (mut node Node) node_install_docker_swarm(args SwarmArgs) ?{
	node.swarm_prepare(args)?
}

pub struct SwarmArgsAdd{
	reset bool
	master Node
}

//specify which node is the master
pub fn (mut node Node) node_install_docker_swarm_add(args SwarmArgsAdd) ?{
	args2 := SwarmArgs{args.reset}
	node.swarm_prepare(args2)?
}
