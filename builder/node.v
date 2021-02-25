module builder

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub struct Node {
	name     string = 'mymachine'
pub mut:
	executor Executor // = ExecutorLocal{}
	platform PlatformType
}

//format ipaddr: localhost:7777
//format ipaddr: 192.168.6.6:7777
//format ipaddr: 192.168.6.6
//format ipaddr: any ipv6 addr
pub struct NodeArguments {
	ipaddr   string
	name     string
	user     string
}

// the factory which returns an node, based on the arguments will chose ssh executor or the local one

pub fn node_get(args NodeArguments) ?Node {
	mut node := Node{}
	if args.ipaddr == '' || args.ipaddr.starts_with('localhost') || args.ipaddr.starts_with('127.0.0.1') {
		node.executor = ExecutorLocal{}
	} else {
		ipaddr := ipaddress_new(args.ipaddr) or {return error("can not initialize ip address")}
		node.executor = ExecutorSSH{ipaddr: ipaddr, user: args.user}
	}
	return node
}
