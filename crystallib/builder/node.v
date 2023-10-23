module builder

import json
import freeflowuniverse.crystallib.data.paramsparser { Params }

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
	intel32
	arm32
}

[heap]
pub struct Node {
mut:
	factory  &BuilderFactory [skip; str: skip]
	executor Executor        [skip; str: skip]
pub:
	name string = 'mymachine'
pub mut:
	platform    PlatformType
	cputype     CPUType
	done        map[string]string
	environment map[string]string
	params      Params
}

// format ipaddr: localhost:7777
// format ipaddr: 192.168.6.6:7777
// format ipaddr: 192.168.6.6
// format ipaddr: any ipv6 addr
// format ipaddr: if only name used then is localhost
[params]
pub struct NodeArguments {
	ipaddr string
	name   string
	user   string = 'root'
	debug  bool
	reload bool
}

// get unique key for the node, as used in caching environment
pub fn (mut node Node) key() string {
	// for now we will use name, but this is not good enough, will have to become something more unique	
	return node.name
}

// get remote environment arguments in memory
pub fn (mut node Node) readfromsystem() ! {
	node.platform_load()!
	node.environment = node.environ_get() or { return error('can not load env.\n ${err}') }
	home := node.environment['HOME'] or {
		return error('could not find HOME in environment variables.\n ${node}')
	}
	node.environment['HOME'] = home.trim_space()
	if node.environment['HOME'] == '' {
		return error('HOME env cannot be empty for ${node.name}')
	}
	node.save()!
}

// load the node from redis cache, if not there will load from system
// return true if the data was in redis (cache)
pub fn (mut node Node) load() !bool {
	data := node.factory.redis.hget('nodes', node.key())!
	if data == '' {
		node.readfromsystem()!
		return false
	}
	data2 := json.decode(Node, data)!

	node.platform = data2.platform
	node.cputype = data2.cputype
	node.done = data2.done.clone()
	node.environment = data2.environment.clone()
	node.params = data2.params
	if node.environment.len == 0 {
		node.readfromsystem()!
	}
	return true
}

// get remote environment arguments in memory
pub fn (mut node Node) save() ! {
	data := json.encode(node)
	node.factory.redis.hset('nodes', node.key(), data)!
}
