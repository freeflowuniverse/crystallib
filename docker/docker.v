module docker

import os
import time
import despiegk.crystallib.builder
import arrays

struct DockerEngine {
pub mut:
	node            builder.Node
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
}

pub struct DockerNodeArguments {
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
	node_ipaddr     string
	node_name       string
	user            string
}

// get a new docker engine
// to use docker.new() -> returns DockerEngine for local machine
// to use docker.new(node_ipaddr:"192.168..10:2222",node_name:"myremoteserver") -> returns DockerEngine for a remote machine, ssh-agent needs to be loaded
// to use docker.new(node_ipaddr:"192.168..10",node_name:"myremoteserver") -> returns DockerEngine for a remote machine on default ssh port 22
pub fn new(args DockerNodeArguments) ?DockerEngine {
	mut node_name := args.node_ipaddr
	if node_name == '' {
		if args.node_ipaddr == '' {
			node_name = 'localnode'
		} else {
			return error('node name cannot be empty if ipaddress is not localhost. ')
		}
	}

	mut node := builder.node_get(ipaddr: args.node_ipaddr, name: node_name, user: args.user) ?
	mut de := DockerEngine{
		node: node
		sshkeys_allowed: args.sshkeys_allowed
	}
	de.init()
	return de
}

// return list of images
pub fn (mut e DockerEngine) images_list() []DockerImage {
	mut res := []DockerImage{}
	mut images := e.node.executor.exec('docker images') or {
		println(err)
		return []DockerImage{}
	}
	mut lines := images.split('\n')
	for line in lines[1..lines.len] {
		info := line.fields()
		mut repo := info[0]
		mut tag := info[1]
		if tag == '<none>' {
			tag = ''
		}
		if repo == '<none>' {
			repo = ''
		}
		id := info[2]
		size := info[info.len - 1]
		mut s := 0.0
		if size.ends_with('GB') {
			s = size.replace('GB', '').f64() * 1024 * 1024 * 1024
		} else if size.ends_with('MB') {
			s = size.replace('MB', '').f64() * 1024 * 1024
		}
		mut details := e.node.executor.exec("docker inspect -f '{{ .Id }} {{ .Created }}' $id") or {
			panic(err)
		}
		splitted := details.split(' ')
		res << DockerImage{
			repo: repo
			tag: tag
			id: splitted[0]
			size: s
			created: splitted[1]
			node: e.node
		}
	}
	return res
}

pub fn (mut e DockerEngine) init() {
	/// Add predefined threefold docker ssh keys to the node
	e.node.executor.exec("echo '$pubkey' > ~/.ssh/threefold.pub && chmod 644 ~/.ssh/threefold.pub") or {
		panic(err)
	}
	e.node.executor.exec("echo '$privkey' > ~/.ssh/threefold && chmod 600 ~/.ssh/threefold") or {
		panic(err)
	}
}

// return list of images
pub fn (mut e DockerEngine) containers_list() []DockerContainer {
	mut res := []DockerContainer{}
	mut images := e.images_list()
	mut containers := e.node.executor.exec('docker ps -a') or {
		println('could not retrieve containers, error executing docker ps -a')
		return []DockerContainer{}
	}
	if containers == '' {
		return res
	}

	mut lines := containers.split('\n')
	for line in lines[1..lines.len] {
		info := line.fields()
		mut id := info[0]
		mut name := info[info.len - 1]

		details := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.Created }} {{.Image}} {{.Config.Image}}'  $id") or {
			println('could not retrieve container info')
			return []DockerContainer{}
		}
		mut splitted := details.split(' ')
		mut container := DockerContainer{
			id: splitted[0]
			created: splitted[1]
			name: name
			node: e.node
			engine: e
		}
		for image in images {
			if image.id == splitted[2] || splitted[3] == '$image.repo:$image.tag' {
				container.image = image
				break
			}
		}
		mut state := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.State}}'  $id") or {
			println(err)
			return []DockerContainer{}
		}
		splitted = state.split(' ')
		splitted.delete(0)
		state = splitted.join(' ')
		container.status = e.parse_container_state(state)

		mut ports := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.HostConfig.PortBindings}}'  $id") or {
			println(err)
			return []DockerContainer{}
		}
		splitted = ports.split(' ')
		splitted.delete(0)
		ports = splitted.join(' ')
		container.forwarded_ports = e.parse_container_ports(ports)

		mut volumes := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.HostConfig.Binds}}'  $id") or {
			println(err)
			return []DockerContainer{}
		}
		splitted = volumes.split(' ')
		splitted.delete(0)
		volumes = splitted.join(' ')
		container.mounted_volumes = e.parse_container_volumes(volumes)
		res << container
	}
	return res
}

// factory class to get a container obj, which can then be filled in and started
pub fn (mut e DockerEngine) container_new() DockerContainer {
	return DockerContainer{
		engine: e
	}
}

pub fn (mut e DockerEngine) container_create(args DockerContainerCreateArgs) ?DockerContainer {
	mut ports := ''
	mut mounts := ''
	mut command := args.command

	for port in args.forwarded_ports {
		ports = ports + '-p $port '
	}

	for mount in args.mounted_volumes {
		mounts += '-v $mount '
	}
	mut image := '$args.image_repo'

	if args.image_tag != '' {
		image = image + ':$args.image_tag'
	}

	if image == 'threefold' || image == 'threefold:latest' || image == '' {
		img := e.build(false) or { panic(err) }
		image = '$img.repo:$img.tag'
		command = '/usr/local/bin/boot.sh'
	}

	// if forwarded ports passed in the args not containing mapping tp ssh (22) create one
	if !e.contains_ssh_port(args.forwarded_ports) {
		// find random free port in the node
		mut port := e.get_free_port()
		ports += '-p $port:22/tcp'
	}

	mut cmd := 'docker run --hostname $args.hostname --name $args.name $ports $mounts -d  -t $image $command'
	e.node.executor.exec(cmd) or { panic(err) }

	mut container := e.container_get(args.name) or { panic(err) }
	mut docker_pubkey := pubkey
	cmd = 'docker exec $container.id sh -c 'echo \"$docker_pubkey\" >> ~/.ssh/authorized_keys''

	if container.node.executor is builder.ExecutorSSH {
		mut sshkey := container.node.executor.info()['sshkey'] + '.pub'
		sshkey = os.read_file(sshkey) or { panic(err) }
		// add pub sshkey on authorized keys of node and container
		cmd = 'echo \"$sshkey\" >> ~/.ssh/authorized_keys && docker exec $container.id sh -c 'echo \"$docker_pubkey\" >> ~/.ssh/authorized_keys && echo \"$sshkey\" >> ~/.ssh/authorized_keys''
	}

	// wait  making sure container started correctly
	time.sleep_ms(200)
	container.node.executor.exec(cmd) ?
	return container
}

pub fn (mut e DockerEngine) container_get(name_or_id string) ?DockerContainer {
	for c in e.containers_list() {
		if c.name == name_or_id || c.id == name_or_id {
			return c
		}
	}
	return error('Cannot find container with name $name_or_id')
}

// import a container into an image, run docker container with it
// image_repo examples ['myimage', 'myimage:latest']
// if DockerContainerCreateArgs contains a name, container will be created and restarted
pub fn (mut e DockerEngine) container_load(path string, mut args DockerContainerCreateArgs) ?DockerContainer {
	mut image := args.image_repo

	if args.image_tag != '' {
		image = image + ':$args.image_tag'
	}

	e.node.executor.exec('docker import  $path $image') or { panic(err) }
	// make sure we start from loaded image
	return e.container_create(args)
}

fn (mut e DockerEngine) parse_container_ports(ports string) []string {
	mut str := ports.trim_right(']').trim_left('map[').trim(' ').replace(']] ', ' ').replace(']]',
		' ').replace('[map[HostIp: HostPort:', '')
	mut res := []string{}
	if str == '' {
		return res
	}
	splitted := str.split(' ')
	for element in splitted {
		ss := element.split(':')
		src := ss[1]
		dest_splitted := ss[0].split('/')
		dest := dest_splitted[0]
		protocol := dest_splitted[1]
		res << '$src:$dest/$protocol'
	}
	return res
}

fn (mut e DockerEngine) parse_container_volumes(volumes string) []string {
	res := volumes.trim_right(']').trim_left('[').trim(' ').trim(' ')
	if res == '' {
		return []string{}
	}
	return res.split(' ')
}

fn (mut e DockerEngine) parse_container_state(state string) DockerContainerStatus {
	if 'Dead:true' in state {
		return DockerContainerStatus.dead
	}
	if 'Paused:true' in state {
		return DockerContainerStatus.paused
	}
	if 'Restarting:true' in state {
		return DockerContainerStatus.restarting
	}
	if 'Running:true' in state {
		return DockerContainerStatus.up
	}
	if 'Status:created' in state {
		return DockerContainerStatus.created
	}
	return DockerContainerStatus.down
}

fn (mut e DockerEngine) contains_ssh_port(forwarded_ports []string) bool {
	for port in forwarded_ports {
		splitted := port.split(':')
		if splitted[1] == '22' || splitted[1] == '22/tcp' {
			return true
		}
	}
	return false
}

// name is repo:tag or image id
pub fn (mut e DockerEngine) image_get(name_or_id string) ?DockerImage {
	mut splitted := name_or_id.split(':')
	mut repo := ''
	mut tag := ''
	mut id := ''

	if splitted.len > 1 {
		repo = splitted[0]
		tag = splitted[1]
	} else if splitted.len == 1 {
		repo = splitted[0]
		id = splitted[0]
	}

	for i in e.images_list() {
		if (i.repo == repo && i.tag == tag) || i.id == id {
			return i
		}
	}
	return error('Cannot find image  $name_or_id')
}

// reset all images & containers, CAREFUL!
pub fn (mut e DockerEngine) reset_all() {
	e.node.executor.exec('docker container rm -f $(docker container ls -aq)') or {}
	e.node.executor.exec('docker image prune -a -f') or { panic(err) }
	e.node.executor.exec('docker builder prune -a -f') or { panic(err) }
}

// Get free port
pub fn (mut e DockerEngine) get_free_port() int {
	mut used_ports := []int{}
	mut range := []int{}

	for c in e.containers_list() {
		for p in c.forwarded_ports {
			used_ports << p.split(':')[0].int()
		}
	}

	for i in 20000 .. 40000 {
		if !(i in used_ports) {
			range << i
		}
	}
	arrays.shuffle<int>(mut range, 0)
	return range[0]
}
