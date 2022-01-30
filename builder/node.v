module builder
import rediscache
import serializers
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





pub struct Node {
pub:
	name string = 'mymachine'	
pub mut:
	executor &Executor // = ExecutorLocal{}
	tmux 	&Tmux
	platform PlatformType
	cputype CPUType
	db &DB [skip]
	done map[string]string
	cache  rediscache.RedisCache [skip]
	environment map[string]string	
}



// format ipaddr: localhost:7777
// format ipaddr: 192.168.6.6:7777
// format ipaddr: 192.168.6.6
// format ipaddr: any ipv6 addr
pub struct NodeArguments {
	ipaddr string
	name   string
	user   string = "root"
	debug  bool
	reset bool
	
}

//get node connection to local machine 
pub fn node_local() ?&Node {
	return node_new(name:"localhost")
}


//retrieve node from the factory, will throw error if not there
pub fn node_get(name string) ?&Node {

	if name==""{
		return error("need to specify name")
	}
	if name in builder.nodes_factory.nodes {
		return builder.nodes_factory.nodes[name] 
	}
	return error("cannot find node $name in nodefactory, please init.")	

}

// the factory which returns an node, based on the arguments will chose ssh executor or the local one
//- format ipaddr: localhost:7777
//- format ipaddr: 192.168.6.6:7777
//- format ipaddr: 192.168.6.6
//- format ipaddr: any ipv6 addr
//- if only name used then is localhost
//
//```
// pub struct NodeArguments {
// 	ipaddr string
// 	name   string
// 	user   string = "root"
// 	debug  bool
// 	reset bool
// 	}
//```
pub fn node_new(args NodeArguments) ?&Node {


	if args.name==""{
		return error("need to specify name")
	}


	if args.name in builder.nodes_factory.nodes{
		return builder.nodes_factory.nodes[args.name] 
	}

	mut node:=Node{executor:&ExecutorLocal{},db:&DB{},tmux: &Tmux{node:args.name}}
	if args.ipaddr == '' || args.ipaddr.starts_with('localhost')
		|| args.ipaddr.starts_with('127.0.0.1') {
		node = Node{name:args.name,db:&DB{},
			executor:&ExecutorLocal{debug: args.debug},
			tmux: &Tmux{node:args.name}
		}
	} else {
		ipaddr := ipaddress_new(args.ipaddr) or { return error('can not initialize ip address') }
		node = Node{name:args.name,db:&DB{},
			executor: &ExecutorSSH{
				ipaddr: ipaddr
				user: args.user
				debug: args.debug
			},
			tmux: &Tmux{node:args.name}
		}
	}

	//is a cache in redis
	node.cache = rediscache.newcache("node:$node.name")

	if args.reset{
		node.cache.reset()?
	}

	node_env_txt := node.cache.get("env") or {
		println( " - env load")
		node.environment_load() ?
		""
	}
	if node_env_txt!=""{
		node.environment = serializers.text_to_map_string_string(node_env_txt)
	}	

	mut db := DB{node: &node}
	home_dir := node.environment['HOME'].trim(" ")
	if home_dir==""{
		return error("HOME env cannot be empty for $node.name")
	}
	db.db_path = '$home_dir/.config/$db.db_dirname'
	node.db = &db

	if args.reset{
		node.db.reset()?
	}

	if !node.cache.exists("env"){
		node.cache.set("env",serializers.map_string_string_to_text(node.environment),3600)?
	}

	init_platform_txt := node.cache.get("platform_type") or {
		println( " - platform load")
		node.platform_load()	
		if db.db_path==""{
			panic("db path cannot be empty")
		}
		node.executor.exec('mkdir -p $db.db_path') ?
		node.cache.set("platform_type",int(node.platform).str(),3600)?
		""
	}
	if init_platform_txt!=""{
		match init_platform_txt.int() {
			0 { node.platform = PlatformType.unknown}
			1 { node.platform = PlatformType.osx}
			2 { node.platform = PlatformType.ubuntu}
			3 { node.platform = PlatformType.alpine}
			else {panic("should not be")}
		}	
	}

	// os.log( " - $node.name: platform: $node.platform")

	init_node_txt := node.cache.get("node_done") or {
		println(err)
		println (" - $node.name: node done needs to be loaded")
		node.done_load()?
		node.cache.set("node_done",serializers.map_string_string_to_text(node.done),600)?
		""
	}
	if init_node_txt!=""{
		node.done = serializers.text_to_map_string_string(init_node_txt)
	}

	if !node.cmd_exists("tmux"){
		os.log("TMUX - could not find tmux command, will try to install, can take a while.")
		node.package_install(name:"tmux")?
	}	

	builder.nodes_factory.nodes[args.name] = &node

	node.tmux.scan()?

	return builder.nodes_factory.nodes[args.name]

}


// get remote environment arguments in memory
pub fn (mut node Node) environment_load() ? {
	node.environment = node.executor.environ_get() or { return error('can not load env') }
}

pub fn (mut node Node) cache_clear() ? {
	node.cache.reset()?
}


