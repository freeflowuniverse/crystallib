module docker

import freeflowuniverse.crystallib.builder
// import freeflowuniverse.crystallib.installers.swarm

// https://docs.docker.com/reference/

[heap]
pub struct DockerEngine {
	name string
pub mut:
	node            builder.Node        [str: skip]
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
	images          []DockerImage
	containers      []DockerContainer
	buildpath       string
	localonly       bool
	cache           bool = true
	push            bool
	platform        []BuildPlatformType
	registries      []DockerRegistry // one or more supported DockerRegistries
	prefix          string
}

pub enum BuildPlatformType {
	linux_arm64
	linux_amd64
}

// check docker has been installed & enabled on node
pub fn (mut e DockerEngine) init() ! {
	if e.buildpath == '' {
		e.buildpath = '/tmp/builder'
		e.node.exec_silent('mkdir -p ${e.buildpath}')!
	}
	if e.platform == [] {
		if e.node.platform == .ubuntu && e.node.cputype == .intel {
			e.platform = [.linux_amd64]
		} else if e.node.platform == .osx && e.node.cputype == .arm {
			e.platform = [.linux_arm64]
		} else {
			return error('only implemented ubuntu on amd and osx on arm for now for docker engine.')
		}
	}
	e.load()!
}

// reload the state from system
pub fn (mut e DockerEngine) load() ! {
	e.images_load()!
	e.containers_load()!
}

// return list of containers
// pub enum DockerContainerStatus {
// 	up
// 	down
// 	restarting
// 	paused
// 	dead
// 	created
// }
// struct DockerContainer {
// pub:
// 	id          string
// 	name        string
// 	hostname    string
// 	created     string
// 	ssh_enabled bool // if yes make sure ssh is enabled to the container
// 	ipaddr 		builder.IPAddress
// 	image           DockerImage
// 	forwarded_ports []string
// 	mounted_volumes []string
// 	ssh_port        int // ssh port on node that is used to get ssh
// 	ports           []string	
// pub mut:
// 	node            string
// 	status          DockerContainerStatus
// }
// }
// return list of images

pub fn (mut e DockerEngine) containers_load() ! {
	e.containers = []DockerContainer{}
	mut lines := e.node.exec_cmd(
		cmd: "docker ps -a --no-trunc --format '{{.ID}}|{{.Names}}|{{.Image}}|{{.Command}}|{{.CreatedAt}}|{{.Ports}}|{{.State}}|{{.Size}}|{{.Mounts}}|{{.Networks}}|{{.Labels}}'"
		ignore_error_codes: [6]
	)!
	for line in lines.split_into_lines() {
		if line.trim_space() == '' {
			continue
		}
		fields := line.split('|').map(clear_str)
		println(fields)
		id := fields[0]
		mut container := DockerContainer{
			image: &DockerImage{
				engine: &e
			}
			engine: &e
		}
		container.id = id
		container.name = fields[1]
		container.image = e.image_get(id: fields[2])!
		container.command = fields[3]
		container.created = parse_time(fields[4])!
		container.ports = parse_ports(fields[5])!
		container.status = parse_container_state(fields[6])!
		container.memsize = parse_size_mb(fields[7])!
		// container.mounts = parse_mounts(fields[8])!
		container.networks = parse_networks(fields[9])!
		container.labels = parse_labels(fields[10])!
		container.ssh_enabled = contains_ssh_port(container.ports)
		e.containers << container
	}
}

// get container from memory, can use match_glob see https://modules.vlang.io/index.html#string.match_glob
pub fn (mut e DockerEngine) container_get(name_or_id string) !&DockerContainer {
	for _, c in e.containers {
		if name_or_id.contains('*') || name_or_id.contains('?') || name_or_id.contains('[') {
			if c.name.match_glob(name_or_id) {
				return &c
			}
		}
		if c.name == name_or_id || c.id == name_or_id {
			return &c
		}
	}
	return error('Cannot find container with name ${name_or_id}')
}

// check existance of container, can use match_glob see https://modules.vlang.io/index.html#string.match_glob
pub fn (mut e DockerEngine) container_exists(name_or_id string) bool {
	for _, c in e.containers {
		if name_or_id.contains('*') || name_or_id.contains('?') || name_or_id.contains('[') {
			if c.name.match_glob(name_or_id) {
				return true
			}
		}
		if c.name == name_or_id || c.id == name_or_id {
			return true
		}
	}
	return false
}

// delete one or more containers, can use match_glob see https://modules.vlang.io/index.html#string.match_glob
pub fn (mut e DockerEngine) container_delete(name_or_id string) ! {
	for _, mut c in e.containers {
		if name_or_id.contains('*') || name_or_id.contains('?') || name_or_id.contains('[') {
			if c.name.match_glob(name_or_id) {
				println(' - docker container delete: ${c.name}')
				c.delete(true)!
			}
		}
		if c.name == name_or_id || c.id == name_or_id {
			c.delete(true)!
		}
	}
	e.load()!
}

// import a container into an image, run docker container with it
// image_repo examples ['myimage', 'myimage:latest']
// if DockerContainerCreateArgs contains a name, container will be created and restarted
pub fn (mut e DockerEngine) container_import(path string, mut args DockerContainerCreateArgs) !&DockerContainer {
	mut image := args.image_repo
	if args.image_tag != '' {
		image = image + ':${args.image_tag}'
	}

	e.node.exec_silent('docker import  ${path} ${image}')!
	// make sure we start from loaded image
	return e.container_create(args)
}

// reset all images & containers, CAREFUL!
pub fn (mut e DockerEngine) reset_all() ! {
	for mut container in e.containers.clone() {
		container.delete(true)!
	}
	for mut image in e.images.clone() {
		image.delete(true)!
	}
	e.node.exec_silent('docker image prune -a -f') or { panic(err) }
	e.node.exec_silent('docker builder prune -a -f') or { panic(err) }
	e.node.done_reset()!
	e.load()!
}

// Get free port
pub fn (mut e DockerEngine) get_free_port() ?int {
	mut used_ports := []int{}
	mut range := []int{}

	for c in e.containers {
		for p in c.forwarded_ports {
			used_ports << p.split(':')[0].int()
		}
	}

	for i in 20000 .. 40000 {
		if i !in used_ports {
			range << i
		}
	}
	// arrays.shuffle<int>(mut range, 0)
	if range.len == 0 {
		return none
	}
	return range[0]
}
