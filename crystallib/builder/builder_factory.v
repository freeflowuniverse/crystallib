module builder

import freeflowuniverse.crystallib.clients.redisclient

@[heap]
pub struct BuilderFactory {
pub mut:
	redis &redisclient.Redis
}

pub fn new() !BuilderFactory {
	mut r := redisclient.core_get()!
	mut bf := BuilderFactory{
		redis: &r
	}
	return bf
}

@[params]
pub struct NodeLocalArgs {
pub:
	reload bool
}

pub fn node_local(args NodeLocalArgs) !&Node {
	mut bldr := new()!
	return bldr.node_new(name: 'localhost', reload: args.reload)
}
