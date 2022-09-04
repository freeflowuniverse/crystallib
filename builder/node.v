module builder

import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.serializers
import os

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
	executor    Executor
pub:
	name string = 'mymachine'
pub mut:      
	cache       redisclient.RedisCache 
	platform    PlatformType
	cputype     CPUType
	done        map[string]string	
	environment map[string]string
	db_path    string="~/builderdb"
	db_state 	   DBState
}


// format ipaddr: localhost:7777
// format ipaddr: 192.168.6.6:7777
// format ipaddr: 192.168.6.6
// format ipaddr: any ipv6 addr
// format ipaddr: if only name used then is localhost
pub struct NodeArguments {
	ipaddr      string
	name        string
	user        string = 'root'
	debug       bool
	reset       bool
	// redis 		&redisclient.Redis //if not specified will be local redisclient	
}

// get node connection to local machine
// pass your redis client there
pub fn (mut builder BuilderFactory) node_local() ?&Node {
	return builder.node_new(name: 'localhost')
}

// retrieve node from the factory, will throw error if not there
pub fn (mut builder BuilderFactory) node_get(name string) ?&Node {
	if name == '' {
		return error('need to specify name')
	}
	if name in builder.nodes {
		return builder.nodes[name]
	}
	return error('cannot find node $name in nodefactory, please init.')
}

// the factory which returns an node, based on the arguments will chose ssh executor or the local one
//- format ipaddr: localhost:7777
//- format ipaddr: 192.168.6.6:7777
//- format ipaddr: 192.168.6.6
//- format ipaddr: any ipv6 addr
//- if only name used then is localhost with localhost executor
//
//```
// pub struct NodeArguments {
// 	ipaddr string
// 	name   string
// 	user   string = "root"
// 	debug  bool
// 	reset bool
//	redisclient &redisclient.Redis
// 	}
//```
pub fn (mut builder BuilderFactory) node_new(args NodeArguments) ?&Node {
	if args.name == '' {
		return error('need to specify name')
	}

	if args.name in builder.nodes {
		return builder.nodes[args.name]
	}

	eargs := ExecutorNewArguments {
		ipaddr:args.ipaddr
		user:args.user
		debug:args.debug
	}
	mut executor:=executor_new(eargs)?
	mut node := Node{
		executor: &executor
		cache: builder.redis.cache('node:$args.name')
	}

	if args.reset {
		node.cache.reset()?
		node.db_reset()?
	}

	node_env_txt := node.cache.get('env') or {
		println(' - env load')
		node.environment_load()?
		''
	}

	if node_env_txt != '' {
		node.environment = serializers.text_to_map_string_string(node_env_txt)
	}

	
	// println(node.environment)
	home_dir := node.environment['HOME'].trim(' ')
	if home_dir == '' {
		return error('HOME env cannot be empty for $node.name')
	}

	if !node.cache.exists('env') {
		node.cache.set('env', serializers.map_string_string_to_text(node.environment),
			3600)?
	}

	init_platform_txt := node.cache.get('platform_type') or {
		println(' - platform load')
		node.platform_load()
		node.db_check()?
		node.cache.set('platform_type', int(node.platform).str(), 3600)?
		''
	}

	if init_platform_txt != '' {
		match init_platform_txt.int() {
			0 { node.platform = PlatformType.unknown }
			1 { node.platform = PlatformType.osx }
			2 { node.platform = PlatformType.ubuntu }
			3 { node.platform = PlatformType.alpine }
			else { panic('should not be') }
		}
	}

	// os.log( " - $node.name: platform: $node.platform")

	init_node_txt := node.cache.get('node_done') or {
		println(err)
		println(' - $node.name: node done needs to be loaded')
		node.done_load()?
		node.cache.set('node_done', serializers.map_string_string_to_text(node.done),
			600)?
		''
	}
	if init_node_txt != '' {
		node.done = serializers.text_to_map_string_string(init_node_txt)
	}

	if !node.cmd_exists('tmux') {
		os.log('TMUX - could not find tmux command, will try to install, can take a while.')
		node.package_install(name: 'tmux')?
	}

	builder.nodes[args.name] = &node

	return builder.nodes[args.name]
}

// get remote environment arguments in memory
pub fn (mut node Node) environment_load() ? {
	node.environment = node.environ_get() or { return error('can not load env') }
}

pub fn (mut node Node) cache_clear() ? {
	node.cache.reset()?
}
