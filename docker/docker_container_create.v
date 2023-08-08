module docker

import freeflowuniverse.crystallib.osal { exec }

pub fn (mut e DockerEngine) container_create(args DockerContainerCreateArgs) !&DockerContainer {
	mut ports := ''
	mut mounts := ''
	mut command := args.command

	for port in args.forwarded_ports {
		ports = ports + '-p ${port} '
	}

	for mount in args.mounted_volumes {
		mounts += '-v ${mount} '
	}
	mut image := '${args.image_repo}'

	if args.image_tag != '' {
		image = image + ':${args.image_tag}'
	}

	if image == 'threefold' || image == 'threefold:latest' || image == '' {
		image = 'threefoldtech/grid3_ubuntu_dev'
		command = '/usr/local/bin/boot.sh'
	}

	privileged:=if args.privileged {'--privileged'} else{''}

	// if forwarded ports passed in the args not containing mapping tp ssh (22) create one
	if !contains_ssh_port(args.forwarded_ports) {
		// find random free port in the node
		mut port := e.get_free_port() or { panic('No free node.') }
		ports += '-p ${port}:22/tcp'
	}

	exec(
		cmd: "docker run --hostname ${args.hostname} ${privileged} --sysctl net.ipv6.conf.all.disable_ipv6=0 --name ${args.name} ${ports} ${mounts} -d  -t ${image} ${command}"
	)!
	//Have to reload the containers as container_get works from memory
	e.containers_load()!
	mut container := e.container_get(name: args.name)!
	return container
}
