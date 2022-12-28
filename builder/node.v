module builder

import freeflowuniverse.crystallib.redisclient

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub enum CPUType {
	unknown
	intel
	arm
}

[heap]
pub struct Node {
mut:
	executor Executor
	db_state DBState
	db_path  string = '~/builderdb'
pub:
	name string = 'mymachine'
pub mut:
	cache       redisclient.RedisCache
	platform    PlatformType
	cputype     CPUType
	done        map[string]string
	environment map[string]string
}

// format ipaddr: localhost:7777
// format ipaddr: 192.168.6.6:7777
// format ipaddr: 192.168.6.6
// format ipaddr: any ipv6 addr
// format ipaddr: if only name used then is localhost
pub struct NodeArguments {
	ipaddr string
	name   string
	user   string = 'root'
	debug  bool
	reset  bool
	// redis 		&redisclient.Redis //if not specified will be local redisclient	
}

// get remote environment arguments in memory
pub fn (mut node Node) environment_load() ! {
	node.environment = node.environ_get() or { return error('can not load env') }
}

pub fn (mut node Node) cache_clear() ! {
	node.cache.reset()!
}
