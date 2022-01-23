module docker
import builder
// import os
// import time
// import arrays

// return list of images
pub fn (mut e DockerEngine) images_list() ?[]DockerImage {
	mut res := []DockerImage{}
	mut node := builder.node_get(e.node)?
	mut lines := node.executor.exec_silent("docker images --format '{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Digest}}|{{.Size}}|{{.CreatedAt}}'")?
	for line in lines.split_into_lines(){
		fields := line.split("|").map(clear_str)
		println(fields)
		panic("ssss")
		res << DockerImage{
			id: fields[0]
			repo: fields[1]
			tag: fields[2]
			digest: fields[3]
			size: size_mb(fields[4])
			created: fields[5]
			// node: ""
		}		
	}
	return res
}

pub fn (mut e DockerEngine) init()? {
	mut node := builder.node_get(e.node)?
	node.install_docker(reset:false)?
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
pub fn (mut e DockerEngine) containers_list() ?[]DockerContainer {
	mut res := []DockerContainer{}
	mut images := e.images_list()?
	mut node := builder.node_get(e.node)?
	mut lines := node.executor.exec_silent("docker ps -a --format '{{.ID}}|{{.Names}}|{{.Image}}|{{.Command}}|{{.CreatedAt}}|{{.Ports}}|{{.State}}|{{.Size}}|{{.Mounts}}|{{.Networks}}|{{.Labels}}'")?
	
	for line in lines.split_into_lines(){
		fields := line.split("|").map(clear_str)
		println(fields)
		panic("ssss2")
		mut container := DockerContainer{
			id: fields[0]
			// created: fields[1]
			// name: fields[2]
		}
		res << container
	}
	return res
}


pub fn (mut e DockerEngine) container_create(args DockerContainerCreateArgs) ?DockerContainer {
	mut ports := ''
	mut mounts := ''
	mut command := args.command
	mut node := builder.node_get(e.node)?

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

	// if image == 'threefold' || image == 'threefold:latest' || image == '' {
	// 	img := e.build(false) or { panic(err) }
	// 	image = '$img.repo:$img.tag'
	// 	command = '/usr/local/bin/boot.sh'
	// }

	// if forwarded ports passed in the args not containing mapping tp ssh (22) create one
	if !e.contains_ssh_port(args.forwarded_ports) {
		// find random free port in the node
		mut port := e.get_free_port()?
		ports += '-p $port:22/tcp'
	}

	mut cmd := 'docker run --hostname $args.hostname --name $args.name $ports $mounts -d  -t $image $command'
	node.executor.exec_silent(cmd)?

	mut container := e.container_get(args.name)?
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
	// container.node.executor.exec(cmd) ?
	return container
}

pub fn (mut e DockerEngine) container_get(name_or_id string) ?DockerContainer {

	mut cl:=e.containers_list()?

	for c in cl {
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
	mut node := builder.node_get(e.node)?

	if args.image_tag != '' {
		image = image + ':$args.image_tag'
	}

	node.executor.exec_silent('docker import  $path $image')?
	// make sure we start from loaded image
	return e.container_create(args)
}

// fn (mut e DockerEngine) parse_container_ports(ports string) []string {

// 	println("---\n$ports\n---")
// 	mut str := ports.trim_right(']').trim_left('map[').trim(' ').replace(']] ', ' ').replace(']]',
// 		' ').replace('[map[HostIp: HostPort:', '')
// 	mut res := []string{}
// 	println("PARSECONTAINER\n$str")
// 	if str == '' {
// 		return res
// 	}
// 	splitted := str.split(' ')
// 	println(splitted)
// 	for element in splitted {
// 		if element.trim(" \n")==""{
// 			continue
// 		}
// 		ss := element.split(':')
// 		src := ss[1]
// 		dest_splitted := ss[0].split('/')
// 		dest := dest_splitted[0]
// 		protocol := dest_splitted[1]
// 		res << '$src:$dest/$protocol'
// 	}
// 	return res
// }

// fn (mut e DockerEngine) parse_container_volumes(volumes string) []string {
// 	res := volumes.trim_right(']').trim_left('[').trim(' ').trim(' ')
// 	if res == '' {
// 		return []string{}
// 	}
// 	return res.split(' ')
// }

fn (mut e DockerEngine) parse_container_state(state string) DockerContainerStatus {
	if state.contains('Dead:true') {
		return DockerContainerStatus.dead
	}
	if state.contains('Paused:true') {
		return DockerContainerStatus.paused
	}
	if state.contains('Restarting:true') {
		return DockerContainerStatus.restarting
	}
	if state.contains('Running:true') {
		return DockerContainerStatus.up
	}
	if state.contains('Status:created') {
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

	mut il:=e.images_list()?

	for i in il {
		if (i.repo == repo && i.tag == tag) || i.id == id {
			return i
		}
	}
	return error('Cannot find image  $name_or_id')
}

// reset all images & containers, CAREFUL!
pub fn (mut e DockerEngine) reset_all()? {
	mut node := builder.node_get(e.node)?
	node.executor.exec_silent('docker container rm -f $(docker container ls -aq) 2>&1 && echo') or {""}
	node.executor.exec_silent('docker image prune -a -f') or { panic(err) }
	node.executor.exec_silent('docker builder prune -a -f') or { panic(err) }
}

// Get free port
pub fn (mut e DockerEngine) get_free_port() ?int {
	mut used_ports := []int{}
	mut range := []int{}

	mut cl:=e.containers_list()?

	for c in cl {
		for p in c.forwarded_ports {
			used_ports << p.split(':')[0].int()
		}
	}

	for i in 20000 .. 40000 {
		if !(i in used_ports) {
			range << i
		}
	}
	// arrays.shuffle<int>(mut range, 0)
	return range[0]
}
