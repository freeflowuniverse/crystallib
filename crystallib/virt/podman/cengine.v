module podman

import freeflowuniverse.crystallib.osal { exec }

@[heap]
pub struct CEngine {
pub mut:
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
	images          []Image
	containers      []Container
	builders     []Builder
	buildpath       string
	localonly       bool
	cache           bool = true
	push            bool
	// platform        []BuildPlatformType // used to build
	// registries      []BAHRegistry    // one or more supported BAHRegistries
	prefix string
}

pub enum BuildPlatformType {
	linux_arm64
	linux_amd64
}

// check podman has been installed & enabled on node
fn (mut e CEngine) init() ! {
	if e.buildpath == '' {
		e.buildpath = '/tmp/builder'
		exec(cmd: 'mkdir -p ${e.buildpath}', stdout: false)!
	}
	// if e.platform == [] {
	// 	if platform() == .ubuntu && cputype() == .intel {
	// 		e.platform = [.linux_amd64]
	// 	} else if platform() == .osx && cputype() == .arm {
	// 		e.platform = [.linux_arm64]
	// 	} else {
	// 		return error('only implemented ubuntu on amd and osx on arm for now for podman engine.')
	// 	}
	// }
	e.load()!
}

// reload the state from system
pub fn (mut e CEngine) load() ! {
	e.builders_load()!
	e.images_load()!
	e.containers_load()!
}


// reset all images & containers, CAREFUL!
pub fn (mut e CEngine) reset_all() ! {
	e.load()!
	for mut container in e.containers.clone() {
		container.delete()!
	}
	for mut image in e.images.clone() {
		image.delete(true)!
	}
	exec(cmd: 'podman rm -a -f', stdout: false)!
	exec(cmd: 'podman rmi -a -f', stdout: false)!
	e.builders_delete_all()!
	osal.done_reset()!
	if osal.platform() == .arch {
		exec(cmd: 'systemctl status podman.socket', stdout: false)!
	}
	e.load()!
}

// Get free port
pub fn (mut e CEngine) get_free_port() ?int {
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

