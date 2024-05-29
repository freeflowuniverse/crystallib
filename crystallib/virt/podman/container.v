module podman

import time
import freeflowuniverse.crystallib.osal { exec }
import freeflowuniverse.crystallib.data.ipaddress { IPAddress }
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.virt.utils
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct Container {
pub mut:
	id              string
	name            string
	created         time.Time
	ssh_enabled     bool // if yes make sure ssh is enabled to the container
	ipaddr          IPAddress
	forwarded_ports []string
	mounts          []utils.ContainerVolume
	ssh_port        int // ssh port on node that is used to get ssh
	ports           []string
	networks        []string
	labels          map[string]string       @[str: skip]
	image           &BAHImage               @[str: skip]
	engine          &CEngine                @[skip; str: skip]
	status          utils.ContainerStatus
	memsize         int // in MB
	command         string
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

// load all containers, they can be consulted in e.containers
// see obj: Container as result in e.containers
pub fn (mut e CEngine) containers_load() ! {
	e.containers = []Container{}
	mut ljob := exec(
		// we used || because sometimes the command has | in it and this will ruin all subsequent columns
		cmd: "podman container list -a --no-trunc --size --format '{{.ID}}||{{.Names}}||{{.ImageID}}||{{.Command}}||{{.CreatedAt}}||{{.Ports}}||{{.State}}||{{.Size}}||{{.Mounts}}||{{.Networks}}||{{.Labels}}'"
		ignore_error_codes: [6]
		stdout: false
	)!
	lines := ljob.output.split_into_lines()
	for line in lines {
		if line.trim_space() == '' {
			continue
		}
		fields := line.split('||').map(utils.clear_str)
		if fields.len < 11 {
			panic('podman ps needs to output 11 parts.\n${fields}')
		}
		id := fields[0]
		// if image doesn't have id skip this container, maybe ran from filesystme
		if fields[2] == '' {
			continue
		}
		mut image := e.image_get(id_full: fields[2])!
		mut container := Container{
			engine: &e
			image: &image
		}
		container.id = id
		container.name = texttools.name_fix(fields[1])
		container.command = fields[3]
		container.created = utils.parse_time(fields[4])!
		container.ports = utils.parse_ports(fields[5])!
		container.status = utils.parse_container_state(fields[6])!
		container.memsize = utils.parse_size_mb(fields[7])!
		container.mounts = utils.parse_mounts(fields[8])!
		container.mounts = []
		container.networks = utils.parse_networks(fields[9])!
		container.labels = utils.parse_labels(fields[10])!
		container.ssh_enabled = utils.contains_ssh_port(container.ports)
		e.containers << container
	}
}

// EXISTS, GET

@[params]
pub struct ContainerGetArgs {
pub mut:
	name     string
	id       string
	image_id string
	// tag    string
	// digest string
}

pub struct ContainerGetError {
	Error
pub:
	args     ContainerGetArgs
	notfound bool
	toomany  bool
}

pub fn (err ContainerGetError) msg() string {
	if err.notfound {
		return 'Could not find image with args:\n${err.args}'
	}
	if err.toomany {
		return 'can not get container, Found more than 1 container with args:\n${err.args}'
	}
	panic('unknown error for ContainerGetError')
}

pub fn (err ContainerGetError) code() int {
	if err.notfound {
		return 1
	}
	if err.toomany {
		return 2
	}
	panic('unknown error for ContainerGetError')
}

// get containers from memory
// params:
//   name   string  (can also be a glob e.g. use *,? and [])
//   id     string
//   image_id string
pub fn (mut e CEngine) containers_get(args_ ContainerGetArgs) ![]&Container {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut res := []&Container{}
	for _, c in e.containers {
		if args.name.contains('*') || args.name.contains('?') || args.name.contains('[') {
			if c.name.match_glob(args.name) {
				res << &c
				continue
			}
		} else {
			if c.name == args.name || c.id == args.id {
				res << &c
				continue
			}
		}
		if args.image_id.len > 0 && c.image.id == args.image_id {
			res << &c
		}
	}
	if res.len == 0 {
		return ContainerGetError{
			args: args
			notfound: true
		}
	}
	return res
}

// get container from memory, can use match_glob see https://modules.vlang.io/index.html#string.match_glob
pub fn (mut e CEngine) container_get(args_ ContainerGetArgs) !&Container {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut res := e.containers_get(args)!
	if res.len > 1 {
		return ContainerGetError{
			args: args
			notfound: true
		}
	}
	return res[0]
}

pub fn (mut e CEngine) container_exists(args ContainerGetArgs) !bool {
	e.container_get(args) or {
		if err.code() == 1 {
			return false
		}
		return err
	}
	return true
}

pub fn (mut e CEngine) container_delete(args ContainerGetArgs) ! {
	mut c := e.container_get(args)!
	c.delete()!
	e.load()!
}

// remove one or more container
pub fn (mut e CEngine) containers_delete(args ContainerGetArgs) ! {
	mut cs := e.containers_get(args)!
	for mut c in cs {
		c.delete()!
	}
	e.load()!
}

// TODO: implement

// import a container into an image, run podman container with it
// image_repo examples ['myimage', 'myimage:latest']
// if ContainerCreateArgs contains a name, container will be created and restarted
// pub fn (mut e CEngine) container_import(path string, mut args ContainerCreateArgs) !&Container {
// 	mut image := args.image_repo
// 	if args.image_tag != '' {
// 		image = image + ':${args.image_tag}'
// 	}

// 	exec(cmd: 'podman import  ${path} ${image}', stdout: false)!
// 	// make sure we start from loaded image
// 	return e.container_create(args)
// }

// create/start container (first need to get a podmancontainer before we can start)
pub fn (mut container Container) start() ! {
	exec(cmd: 'podman start ${container.id}')!
	container.status = utils.ContainerStatus.up
}

// delete podman container
pub fn (mut container Container) halt() ! {
	osal.execute_stdout('podman stop ${container.id}') or { '' }
	container.status = utils.ContainerStatus.down
}

// delete podman container
pub fn (mut container Container) delete() ! {
	console.print_debug(' CONTAINER DELETE: ${container.name}')
	cmd := 'podman rm ${container.id} -f'
	console.print_debug(cmd)
	exec(cmd: cmd, stdout: false)!
}

// save the podman container to image
pub fn (mut container Container) save2image(image_repo string, image_tag string) !string {
	id := osal.execute_stdout('podman commit ${container.id} ${image_repo}:${image_tag}')!

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
