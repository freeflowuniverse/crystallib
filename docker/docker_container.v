module docker

import builder

pub enum DockerContainerStatus {
	up
	down
	restarting
	paused
	dead
	created
}

// need to fill in what is relevant
struct DockerContainer {
pub:
	id          	string
	name        	string
	hostname    	string
	created    		string
	ssh_enabled 	bool // if yes make sure ssh is enabled to the container
	info        	DockerContainerInfo
	
	
	engine			DockerEngine

pub mut:
	node        builder.Node
	image       DockerImage
	status      DockerContainerStatus
	ports       	[]string
	forwarded_ports	[]string
	mounted_volumes	[]string
	ssh_port        int //ssh port on node that is used to get ssh
}

struct DockerContainerInfo {
	ipaddr builder.IPAddress
}

struct DockerContainerVolume{
	src 	string
	dest	string
}

pub struct DockerContainerCreateArgs{
	name        	string
	hostname    	string
	forwarded_ports	[]string // ["80:9000/tcp", "1000, 10000/udp"]
	mounted_volumes	[]string // ["/root:/root", ]
	pub mut:
		image_repo      string
		image_tag       string
		command			string = "/bin/bash"

}

// create/start container (first need to get a dockercontainer before we can start)
pub fn (mut container DockerContainer) start() ?string {
	c := container.node.executor.exec('docker start $container.id') or {panic(err)}
	container.status = DockerContainerStatus.up
	return c
}

// delete docker container
pub fn (mut container DockerContainer) halt() ?string {
	c := container.node.executor.exec('docker stop $container.id') or {panic(err)}
	container.status = DockerContainerStatus.down
	return c
}

// delete docker container
pub fn (mut container DockerContainer) delete(force bool) ?string {
	if force {
		return container.node.executor.exec('docker rm -f $container.id')
	}
	return container.node.executor.exec('docker rm $container.id')
}

// save the docker container to image
pub fn (mut container DockerContainer) save2image(image_repo string, image_tag string) ?string {
	
	id := container.node.executor.exec('docker commit $container.id $image_repo:$image_tag') or {panic(err)}
	container.image.id = id
	return id
}

// export docker to tgz
pub fn (mut container DockerContainer) export(path string) ?string {
	return container.node.executor.exec('docker export $container.id > $path')
}

// open ssh shell to the cobtainer
pub fn (mut container DockerContainer) ssh_shell() ? {
	container.node.executor.ssh_shell(container.ssh_port)?
}

// return the builder.node class which allows to remove executed, ...
pub fn (mut container DockerContainer) node_get() ?builder.Node {
	return container.node
}
