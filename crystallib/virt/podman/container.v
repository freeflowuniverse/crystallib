module podman

import freeflowuniverse.crystallib.osal { exec }
import time
import freeflowuniverse.crystallib.data.ipaddress { IPAddress }

pub enum ContainerStatus {
	up
	down
	restarting
	paused
	dead
	created
}

// need to fill in what is relevant
@[heap]
pub struct Container {
pub mut:
	id              string
	name            string
	created         time.Time
	ssh_enabled     bool // if yes make sure ssh is enabled to the container
	ipaddr          IPAddress
	forwarded_ports []string
	mounts          []ContainerVolume
	ssh_port        int // ssh port on node that is used to get ssh
	ports           []string
	networks        []string
	labels          map[string]string       @[str: skip]
	image           &BAHImage            @[str: skip]
	engine          &CEngine           @[str: skip]
	status          ContainerStatus
	memsize         int // in MB
	command         string
}

pub struct ContainerVolume {
	src  string // TODO: is this in container? suggest to change src -> containerpath na dest->hostpath
	dest string
}

@[params]
pub struct ContainerCreateArgs {
	name             string
	hostname         string
	forwarded_ports  []string // ["80:9000/tcp", "1000, 10000/udp"]
	mounted_volumes  []string // ["/root:/root", ]
	env              map[string]string // map of environment variables that will be passed to the container
	privileged       bool
	remove_when_done bool = true // remove the container when it shuts down
pub mut:
	image_repo string
	image_tag  string
	command    string = '/bin/bash'
}

// create/start container (first need to get a podmancontainer before we can start)
pub fn (mut container Container) start() ! {
	exec(cmd: 'podman start ${container.id}')!
	container.status = ContainerStatus.up
}

// delete podman container
pub fn (mut container Container) halt() ! {
	osal.execute_stdout('podman stop ${container.id}') or { '' }
	container.status = ContainerStatus.down
}

// delete podman container
pub fn (mut container Container) delete() ! {
	println(' CONTAINER DELETE: ${container.name}')

	exec(cmd: 'podman rm ${container.id} -f', stdout: false)!
	mut x := 0
	for container2 in container.engine.containers {
		if container2.name == container.name {
			container.engine.containers.delete(x)
		}
		x += 1
	}
}

// save the podman container to image
pub fn (mut container Container) save2image(image_repo string, image_tag string) !string {
	id := osal.execute_stdout('podman commit ${container.id} ${image_repo}:${image_tag}')!
	container.image.id = id.trim(' ')
	return id
}

// export podman to tgz
pub fn (mut container Container) export(path string) ! {
	exec(cmd: 'podman export ${container.id} > ${path}')!
}

// // open ssh shell to the cobtainer
// pub fn (mut container Container) ssh_shell(cmd string) ! {
// 	container.engine.node.shell(cmd)!
// }

@[params]
pub struct BAHShellArgs {
pub mut:
	cmd string
}

// open shell to the container using podman, is interactive, cannot use in script
pub fn (mut container Container) shell(args BAHShellArgs) ! {
	mut cmd := ''
	if args.cmd.len == 0 {
		cmd = 'podman exec -ti ${container.id} /bin/bash'
	} else {
		cmd = "podman exec -ti ${container.id} /bin/bash -c '${args.cmd}'"
	}
	exec(cmd: cmd, shell: true, debug: true)!
}

pub fn (mut container Container) execute(cmd_ string, silent bool) ! {
	cmd := 'podman exec ${container.id} ${cmd_}'
	exec(cmd: cmd, stdout: !silent)!
}

// pub fn (mut container Container) ssh_enable() ! {
// 	// mut podman_pubkey := pubkey
// 	// cmd = "podman exec $container.id sh -c 'echo \"$podman_pubkey\" >> ~/.ssh/authorized_keys'"

// 	// if container.engine.node.executor is builder.ExecutorSSH {
// 	// 	mut sshkey := container.engine.node.executor.info()['sshkey'] + '.pub'
// 	// 	sshkey = os.read_file(sshkey) or { panic(err) }
// 	// 	// add pub sshkey on authorized keys of node and container
// 	// 	cmd = "echo \"$sshkey\" >> ~/.ssh/authorized_keys && podman exec $container.id sh -c 'echo \"$podman_pubkey\" >> ~/.ssh/authorized_keys && echo \"$sshkey\" >> ~/.ssh/authorized_keys'"
// 	// }

// 	// wait  making sure container started correctly
// 	// time.sleep_ms(100 * time.millisecond)
// 	// container.engine.node.executor.exec(cmd) !	
// }
