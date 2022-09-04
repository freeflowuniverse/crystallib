module builder

import redisclient

[heap]
pub struct BuilderFactory {
pub mut:
	nodes map[string]&Node
	redis &redisclient.Redis
}

fn new(redisclient redisclient.Redis) BuilderFactory {
	mut bf := BuilderFactory{
		redisclient: redisclient
	}
}
