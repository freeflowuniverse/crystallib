

module builder

pub struct SwarmArgs{
	reset bool
}

//installs docker & swarm
pub fn (mut node Node) install_docker(args SwarmArgs) ?{

	node.platform_prepare()?
	// was_done := node.crystaltools_install()?
	// if was_done{
	// 	node.crystaltools_update(reset:args.reset)?
	// }
	// node.upgrade()?

	docker_install := '
		apt-get install ca-certificates curl sudo gnupg lsb-release screen -y

		#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

		#echo \
		#"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		#$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

		add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

		apt-get update
		apt-get install docker-ce docker-ce-cli containerd.io -y

	'
	// docker_install := '
	// 	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	// 	#THIS IS FOR UBUNTU 20.04 (focal)
	// 	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	// 	apt update
	// 	apt install docker-ce -y
	// 	systemctl start docker
	// 	systemctl enable docker
	// 	'
	node.exec(cmd:docker_install,reset:args.reset,description:"install docker.")?

	mut w:= node.tmux.window_new(name:"docker",cmd:"dockerd",reset:true)?

	for _ in 1..100 {
		out := node.executor.exec('docker info') or {
			if err.msg.contains("Cannot connect to the Docker daemon"){
				"noconnection"
			}
			err.msg
		}
		if out == "noconnection" {
			panic("SSSSS")
		}	
	}
	// NOW WE NEED TO CHECK OF DOCKER ANSWERS

}

//install swarm management solution
pub fn (mut node Node) install_portainer() ?{
	install := '
		set -ex
		cd /tmp
		curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
		docker stack deploy -c portainer-agent-stack.yml portainer
		'
	node.exec(cmd:install,reset:false,description:"install portainer.")?

	// >TODO: check that the ubuntu is focal

}


pub fn (mut node Node) docker_swarm_install(args SwarmArgs) ?{
	
	node.install_docker(args)?
	ipaddr_master := node.ipaddr_pub_get()?
	cmd := "docker swarm init --advertise-addr $ipaddr_master"
	node.exec(cmd:cmd,reset:args.reset,description:"swarm init.")?

}

pub struct SwarmArgsAdd{
pub mut:	
	reset bool
	master Node
}

//specify which node is the master
pub fn (mut node Node) docker_swarm_install_add(mut args SwarmArgsAdd) ?{
	args2 := SwarmArgs{args.reset}
	ipaddr := args.master.ipaddr_pub_get()?

	mut token := args.master.executor.exec("docker swarm join-token worker -q")?
	token = token.trim("\n").trim(" \n")

	node.install_docker(args2)?
	
	cmd := "docker swarm leave && docker swarm join --token  $token ${ipaddr}:2377"
	println(cmd)
	node.exec(cmd:cmd,reset:args.reset,description:"swarm init.")?	
}
