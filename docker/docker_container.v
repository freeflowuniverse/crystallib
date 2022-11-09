module docker

import time
import ipaddress { IPAddress }
import freeflowuniverse.crystallib.builder

pub enum DockerContainerStatus {
	up
	down
	restarting
	paused
	dead
	created
}

// need to fill in what is relevant
[heap]
struct DockerContainer {
pub mut:
	id              string
	name            string
	created         time.Time
	ssh_enabled     bool // if yes make sure ssh is enabled to the container
	ipaddr          IPAddress
	forwarded_ports []string
	mounts          []DockerContainerVolume
	ssh_port        int // ssh port on node that is used to get ssh
	ports           []string
	networks        []string
	labels          map[string]string
	image           &DockerImage
	engine          string // name of docker engine
	node            string // reference to node over ssh into container
	status          DockerContainerStatus
	memsize         int // in MB
	command         string
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

// get the node from docker engine
pub fn (mut container DockerContainer) node() &builder.Node {
	mut e := engine_get(container.engine) or {
		panic('bug: should always find this engine: $container.engine')
	}
	mut factory := builder.new() 
	mut node := factory.node_get(e.node) or { panic('bug: should always find this node: $e.node') }
	return node
}

// create/start container (first need to get a dockercontainer before we can start)
pub fn (mut container DockerContainer) start() !string {
	mut node := container.node()
	c := node.exec_silent('docker start $container.id')!
	container.status = DockerContainerStatus.up
	return c
}

// delete docker container
pub fn (mut container DockerContainer) halt() !string {
	mut node := container.node()
	c := node.exec_silent('docker stop $container.id') or { '' }
	container.status = DockerContainerStatus.down
	return c
}

// delete docker container
pub fn (mut container DockerContainer) delete(force bool) ! {
	mut node := container.node()
	println(' - CONTAINER DELETE: $container.name')
	if force {
		node.exec_silent('docker rm -f $container.id')!
	} else {
		node.exec_silent('docker rm $container.id')!
	}
}

// save the docker container to image
pub fn (mut container DockerContainer) save2image(image_repo string, image_tag string) !string {
	mut node := container.node()
	id := node.exec_silent('docker commit $container.id $image_repo:$image_tag')!
	container.image.id = id
	return id
}

// export docker to tgz
pub fn (mut container DockerContainer) export(path string) !string {
	mut node := container.node()
	return node.exec_silent('docker export $container.id > $path')
}

// open ssh shell to the cobtainer
pub fn (mut container DockerContainer) ssh_shell(cmd string) ! {
	mut node := container.node_container_get()!
	node.shell(cmd)!
}

// open shell to the container using docker, is interactive, cannot use in script
pub fn (mut container DockerContainer) shell(cmd string) ! {
	mut node := container.node()
	mut cmd2 := ''
	if cmd.len == 0 {
		cmd2 = 'docker exec -ti $container.id /bin/bash'
	} else {
		cmd2 = "docker exec -ti $container.id /bin/bash -c '$cmd'"
	}
	println(cmd2)
	node.shell(cmd2)!
}

// ret

// return the builder.node class which allows to remove executed, ...
pub fn (mut container DockerContainer) node_container_get() !&builder.Node {
	mut factory := builder.new() 
	mut node := factory.node_get(container.node)!
	return node
}

pub fn (mut container DockerContainer) execute(cmd_ string, silent bool) ! {
	mut node := container.node()
	cmd := 'docker exec $container.id $cmd_'
	if silent {
		node.exec_silent(cmd)!
	} else {
		node.exec(cmd)!
	}
}

pub fn (mut container DockerContainer) ssh_enable() !&builder.Node {
	// mut docker_pubkey := pubkey
	// cmd = "docker exec $container.id sh -c 'echo \"$docker_pubkey\" >> ~/.ssh/authorized_keys'"

	// if container.node.executor is builder.ExecutorSSH {
	// 	mut sshkey := container.node.executor.info()['sshkey'] + '.pub'
	// 	sshkey = os.read_file(sshkey) or { panic(err) }
	// 	// add pub sshkey on authorized keys of node and container
	// 	cmd = "echo \"$sshkey\" >> ~/.ssh/authorized_keys && docker exec $container.id sh -c 'echo \"$docker_pubkey\" >> ~/.ssh/authorized_keys && echo \"$sshkey\" >> ~/.ssh/authorized_keys'"
	// }

	// wait  making sure container started correctly
	// time.sleep_ms(200)
	// container.node.executor.exec(cmd) !	

	mut node := container.node()
	return node
}
