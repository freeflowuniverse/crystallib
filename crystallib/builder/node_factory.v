module builder

// get node connection to local machine
// pass your redis client there
pub fn (mut builder BuilderFactory) node_local() !&Node {
	return builder.node_new(name: 'localhost')
}

// retrieve node from the factory, will throw error if not there
pub fn (mut builder BuilderFactory) node_get(name string) !&Node {
	if name == '' {
		return error('need to specify name')
	}
	for node in builder.nodes {
		if node.name == name {
			return &node
		}
	}
	return error("can't find node '${name}'")
}

// format ipaddr: localhost:7777 .
// format ipaddr: 192.168.6.6:7777 .
// format ipaddr: 192.168.6.6 .
// format ipaddr: any ipv6 addr .
// format ipaddr: if only name used then is localhost .
[params]
pub struct NodeArguments {
pub mut:
	ipaddr string
	name   string = 'default'
	user   string = 'root'
	debug  bool
	reload bool
}


// the factory which returns an node, based on the arguments will chose ssh executor or the local one
// .
//```
// - format ipaddr: localhost:7777
// - format ipaddr: myuser@192.168.6.6:7777
// - format ipaddr: 192.168.6.6
// - format ipaddr: any ipv6 addr
// - if only name used then is localhost with localhost executor
//``` 
// its possible to put a user as user@ .. in front of an ip addr .
// .
//```
// pub struct NodeArguments {
// 	ipaddr string
// 	name   string
// 	user   string = "root"
// 	debug  bool
// 	reset bool
// 	}
//```
pub fn (mut builder BuilderFactory) node_new(args_ NodeArguments) !&Node {
	mut args:=args_
	if args.name == '' {
		return error('need to specify name')
	}

	for node in builder.nodes {
		if node.name == args.name {
			return &node
		}
	}

	if args.ipaddr.contains("@"){
		args.user ,args.ipaddr = args.ipaddr.split_once('@') or {panic('bug')}
	}

	eargs := ExecutorNewArguments{
		ipaddr: args.ipaddr
		user: args.user
		debug: args.debug
	}
	mut executor := executor_new(eargs)!
	mut node := Node{
		name: args.name
		executor: executor
		factory: &builder
	}

	wasincache := node.load()!

	if wasincache && args.reload {
		node.readfromsystem()!
	}

	builder.nodes << node

	return &node
}
