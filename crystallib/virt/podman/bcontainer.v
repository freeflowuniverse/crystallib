
module podman

import json
import freeflowuniverse.crystallib.osal

// is builderah containers

// pub enum ContainerStatus {
// 	up
// 	down
// 	restarting
// 	paused
// 	dead
// 	created
// }

// need to fill in what is relevant
@[heap]
pub struct BContainer {
pub mut:
	id            string
	builder       bool
	imageid       string
	imagename     string
	containername string
	engine        &CEngine @[skip; str: skip]
	// created         time.Time
	// ssh_enabled     bool // if yes make sure ssh is enabled to the container
	// ipaddr          IPAddress
	// forwarded_ports []string
	// mounts          []ContainerVolume
	// ssh_port        int // ssh port on node that is used to get ssh
	// ports           []string
	// networks        []string
	// labels          map[string]string       @[str: skip]
	// image           &BAHImage            @[str: skip]
	// engine          &CEngine           @[str: skip]
	// status          ContainerStatus
	// memsize         int // in MB
	// command         string
}

pub fn (mut e CEngine) bcontainers_load() ! {
	cmd := 'buildah containers --json'
	out := osal.execute_silent(cmd)!
	mut r := json.decode([]BContainer, out) or { return error('Failed to decode JSON: ${err}') }
	for mut item in r {
		item.engine = &e
	}
	e.bcontainers = r
}

// get buildah containers
pub fn (mut e CEngine) bcontainers() ![]BContainer {
	if e.bcontainers.len == 0 {
		e.bcontainers_load()!
	}
	return e.bcontainers
}

pub fn (mut e CEngine) bcontainer_exists(name string) !bool {
	r := e.bcontainers()!
	res := r.filter(it.containername == name)
	if res.len == 1 {
		return true
	}
	if res.len > 1 {
		panic('bug')
	}
	return false
}

pub fn (mut e CEngine) bcontainer_get(name string) !BContainer {
	r := e.bcontainers()!
	res := r.filter(it.containername == name)
	if res.len == 1 {
		return res[0]
	}
	if res.len > 1 {
		panic('bug')
	}
	return error('couldnt find container with name ${name}')
}

pub fn (mut e CEngine) bcontainers_delete_all() ! {
	osal.execute_stdout('buildah rm -a')!
}

pub fn (mut e CEngine) bcontainer_delete(name string) ! {
	if e.bcontainer_exists(name)! {
		osal.execute_stdout('buildah rm ${name}')!
	}
}

pub fn (mut e CEngine) bnames() ![]string {
	r := e.bcontainers()!
	return r.map(it.containername)
}

@[params]
pub struct BContainerNewArgs {
pub mut:
	name         string @[required]
	from         string = 'docker.io/archlinux:latest'
	arch_scratch bool // means start from scratch with arch linux
	delete       bool = true
}

pub fn (mut e CEngine) bcontainer_new(args_ BContainerNewArgs) !BContainer {
	mut args := args_
	if args.delete {
		e.bcontainer_delete(args.name)!
	}
	osal.exec(cmd: 'buildah --name ${args.name} from ${args.from}')!
	e.bcontainers_load()!
	return e.bcontainer_get(args.name)
}

pub fn (mut self BContainer) delete() ! {
	self.engine.bcontainer_delete(self.containername)!
}

pub fn (mut self BContainer) inspect() !ContainerInfo {
	cmd := 'buildah inspect ${self.containername}'
	out := osal.execute_silent(cmd)!
	mut r := json.decode(ContainerInfo, out) or {
		return error('Failed to decode JSON for inspect: ${err}')
	}
	return r
}

pub fn (mut self BContainer) mount_to_path() !string {
	cmd := 'buildah mount ${self.containername}'
	return osal.execute_silent(cmd)!
}

pub fn (mut self BContainer) commit(image_name string) ! {
	cmd := 'buildah commit ${self.containername} ${image_name}'
	osal.exec(cmd: cmd)!
}

pub fn (self BContainer) set_entrypoint(entrypoint string) !{
	cmd := 'buildah config --entrypoint ${entrypoint} ${self.containername}'
	osal.exec(cmd: cmd)!
}