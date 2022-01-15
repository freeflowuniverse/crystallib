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
	id          string
	name        string
	hostname    string
	created     string
	ssh_enabled bool // if yes make sure ssh is enabled to the container
	ipaddr 		builder.IPAddress
	image           DockerImage
	forwarded_ports []string
	mounted_volumes []string
	ssh_port        int // ssh port on node that is used to get ssh
	ports           []string	
pub mut:
	node            string
	status          DockerContainerStatus
}

struct DockerContainerInfo {
	ipaddr builder.IPAddress
}

struct DockerContainerVolume {
	src  string
	dest string
}

pub struct DockerContainerCreateArgs {
	name            string
	hostname        string
	forwarded_ports []string // ["80:9000/tcp", "1000, 10000/udp"]
	mounted_volumes []string // ["/root:/root", ]
pub mut:
	image_repo string
	image_tag  string
	command    string = '/bin/bash'
}

// create/start container (first need to get a dockercontainer before we can start)
pub fn (mut container DockerContainer) start() ?string {
	c := container.node.executor.exec_silent('docker start $container.id') ?
	container.status = DockerContainerStatus.up
	return c
}

// delete docker container
pub fn (mut container DockerContainer) halt() ?string {
	c := container.node.executor.exec_silent('docker stop $container.id')or {""}
	container.status = DockerContainerStatus.down
	return c
}

// delete docker container
pub fn (mut container DockerContainer) delete(force bool) ?string {
	if force {
		return container.node.executor.exec_silent('docker rm -f $container.id')
	}
	return container.node.executor.exec_silent('docker rm $container.id')
}

// save the docker container to image
pub fn (mut container DockerContainer) save2image(image_repo string, image_tag string) ?string {
	id := container.node.executor.exec_silent('docker commit $container.id $image_repo:$image_tag')?
	container.image.id = id
	return id
}

// export docker to tgz
pub fn (mut container DockerContainer) export(path string) ?string {
	return container.node.executor.exec_silent('docker export $container.id > $path')
}

// open ssh shell to the cobtainer
pub fn (mut container DockerContainer) ssh_shell() ? {
	container.node.executor.shell() ?
}

// return the builder.node class which allows to remove executed, ...
pub fn (mut container DockerContainer) node_get() ?builder.Node {
	return container.node
}
