module docker

import time
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.swarm

// https://docs.docker.com/reference/

[heap]
struct DockerEngine {
	name string
pub mut:
	node            string = 'localhost'
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
	images          []&DockerImage
	containers      map[string]&DockerContainer
}

// check docker has been installed & enabled on node
pub fn (mut e DockerEngine) init()! {
	mut factory := builder.new()
	mut node := factory.node_get(e.node)!
	mut installer := swarm.get(mut node)
	installer.install_docker(reset: false)!
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
	mut factory := builder.new()
	mut node := factory.node_get(e.node)!
	mut lines := node.exec_silent("docker ps -a --no-trunc --format '{{.ID}}|{{.Names}}|{{.Image}}|{{.Command}}|{{.CreatedAt}}|{{.Ports}}|{{.State}}|{{.Size}}|{{.Mounts}}|{{.Networks}}|{{.Labels}}'")!

	for line in lines.split_into_lines() {
		fields := line.split('|').map(clear_str)
		println(fields)
		id := fields[0]
		if id !in e.containers {
			mut dc := DockerContainer{
				image: &DockerImage{}
			}
			e.containers[id] = &dc
		}
		mut container := e.containers[id]
		container.id = id
		container.name = fields[1]
		container.image = e.image_get_from_name(fields[2])
		container.command = fields[3]
		container.created = parse_time(fields[4])!
		container.ports = parse_ports(fields[5])!
		container.status = parse_container_state(fields[6])!
		container.memsize = parse_size_mb(fields[7])!
		// container.mounts = parse_mounts(fields[8])!
		container.networks = parse_networks(fields[9])!
		container.labels = parse_labels(fields[10])!
		container.ssh_enabled = contains_ssh_port(container.ports)
		container.node = node.name
		container.engine = e.name
	}
}

pub fn (mut e DockerEngine) containers_get() ?[]&DockerContainer {
	mut res := []&DockerContainer{}
	if e.containers.len == 0 { return none }
	for _, container in e.containers {
		res << container
	}
	return res
}

// get container from memory
pub fn (mut e DockerEngine) container_get(name_or_id string) !&DockerContainer {
	for _, c in e.containers {
		if c.name == name_or_id || c.id == name_or_id {
			return c
		}
	}
	return error('Cannot find container with name $name_or_id')
}

pub fn (mut e DockerEngine) container_delete(name_or_id string) ! {
	for _, mut c in e.containers {
		if c.name == name_or_id || c.id == name_or_id {
			c.delete(true)!
		}
	}
}

// return list of images
pub fn (mut e DockerEngine) images_list() ![]&DockerImage {
	e.images_load()!
	return e.images
}

pub fn (mut e DockerEngine) images_load() ! {
	mut factory := builder.new()
	mut node := factory.node_get(e.node)!
	mut lines := node.exec_silent("docker images --format '{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Digest}}|{{.Size}}|{{.CreatedAt}}'")!
	for line in lines.split_into_lines() {
		fields := line.split('|').map(clear_str)
		mut obj := e.image_get(fields[1], fields[2])
		obj.id = fields[0]
		obj.digest = parse_digest(fields[3]) or { '' }
		obj.size = parse_size_mb(fields[4]) or { 0 }
		obj.created = parse_time(fields[5]) or { time.now() }
		obj.node = node.name
	}
}

pub fn (mut e DockerEngine) image_get_from_id(id string) !&DockerImage {
	for i in e.images {
		if i.id == id {
			return i
		}
	}
	return error('Cannot find image with id: $id')
}

// name is e.g. docker/getting-started:latest
pub fn (mut e DockerEngine) image_get_from_name(name string) &DockerImage {
	if name.contains(':') {
		splitted := name.split(':').map(clear_str)
		repo := splitted[0]
		tag := splitted[1]
		return e.image_get(repo, tag)
	} else {
		return e.image_get(name, '')
	}
}

// find image based on repo and optional tag
// if not found will initialize the image object and add to collection
pub fn (mut e DockerEngine) image_get(repo string, tag string) &DockerImage {
	for i in e.images {
		if i.repo == repo && i.tag == tag {
			return i
		}
		if i.repo == repo && i.tag == 'latest' && tag == '' {
			return i
		}
		if i.repo == repo && i.tag == '' && tag == 'latest' {
			return i
		}
	}
	mut di := DockerImage{}
	if tag.len > 0 {
		di = DockerImage{
			repo: repo
			tag: tag
		}
	} else {
		di = DockerImage{
			repo: repo
		}
	}
	e.images << &di
	return &di
}

// import a container into an image, run docker container with it
// image_repo examples ['myimage', 'myimage:latest']
// if DockerContainerCreateArgs contains a name, container will be created and restarted
pub fn (mut e DockerEngine) container_import(path string, mut args DockerContainerCreateArgs) !&DockerContainer {
	mut image := args.image_repo
	mut factory := builder.new()
	mut node := factory.node_get(e.node)!

	if args.image_tag != '' {
		image = image + ':$args.image_tag'
	}

	node.exec_silent('docker import  $path $image')!
	// make sure we start from loaded image
	return e.container_create(args)
}

// reset all images & containers, CAREFUL!
pub fn (mut e DockerEngine) reset_all() ! {
	mut factory := builder.new()
	mut node := factory.node_get(e.node)!
	node.exec_silent('docker container rm -f $(docker container ls -aq) 2>&1 && echo') or {
		panic(err)
	}
	node.exec_silent('docker image prune -a -f') or { panic(err) }
	node.exec_silent('docker builder prune -a -f') or { panic(err) }
	e.images = []&DockerImage{}
	e.containers = map[string]&DockerContainer{}
	e.load()!
}

// Get free port
pub fn (mut e DockerEngine) get_free_port() ?int {
	mut used_ports := []int{}
	mut range := []int{}

	mut cl := e.containers_get() or {[]&DockerContainer{}}

	for c in cl {
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
	if range.len == 0 { return none }
	return range[0]
}
