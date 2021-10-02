module builder

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub struct Node {
	name string = 'mymachine'
pub mut:
	executor &Executor // = ExecutorLocal{}
	platform PlatformType
	db &DB [skip]
	done map[string]string
}

// format ipaddr: localhost:7777
// format ipaddr: 192.168.6.6:7777
// format ipaddr: 192.168.6.6
// format ipaddr: any ipv6 addr
pub struct NodeArguments {
	ipaddr string
	name   string
	user   string = "root"
}

// the factory which returns an node, based on the arguments will chose ssh executor or the local one
// ipaddr e.g. 192.12.2.2:44  (port is optionally specified in string)
pub fn node_get(args NodeArguments) ?Node {
	mut node:=Node{executor:&ExecutorLocal{},db:&DB{}}
	if args.ipaddr == '' || args.ipaddr.starts_with('localhost')
		|| args.ipaddr.starts_with('127.0.0.1') {
		node = Node{name:args.name,executor:&ExecutorLocal{},db:&DB{}}
	} else {
		ipaddr := ipaddress_new(args.ipaddr) or { return error('can not initialize ip address') }
		node = Node{name:args.name,db:&DB{},executor:
			&ExecutorSSH{
				ipaddr: ipaddr
				user: args.user
			}
		}
	}
	mut db := DB{node: &node}
	db.environment_load() ?
	node.platform_load()	
	// node.executor.debug_on()
	node.executor.exec('mkdir -p $db.db_path()') ?
	node.db = &db
	node.done_load()?
	// make sure the db path exists
	return node

}
