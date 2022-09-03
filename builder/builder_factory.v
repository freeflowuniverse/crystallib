module builder
import redisclient

[heap]
pub struct BuilderFactory {
pub mut:
	nodes map[string]&Node
	redis &redisclient.Redis
}


fn new() BuilderFactory{
	mut bf := BuilderFactory{}
}

//return local node
fn (mut BuilderFactory) node_local(){

}