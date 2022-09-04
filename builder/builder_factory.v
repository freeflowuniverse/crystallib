module builder

import redisclient

[heap]
pub struct BuilderFactory {
pub mut:
	nodes map[string]&Node
	redis &redisclient.Redis
}

pub fn new() BuilderFactory {
	mut r:=redisclient.core_get()
	mut bf := BuilderFactory{
		redis: &r
	}
	return bf
}
