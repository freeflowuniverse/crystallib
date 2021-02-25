struct GitRepo {
pub:
	path        string
	addr 		GitAddr
pub mut:
	state       GitStatus
}

//is just a test, meaningless
struct GitAddr {
	pub:
		addr string
}

pub enum GitStatus {
	unknown
	changes
	ok
	error
}


fn main(){
	mut gr := GitRepo{path:"a path", addr:GitAddr{addr:"myaddr"}}
	gr.state = GitStatus.ok
	println(gr)
	gr.state = GitStatus.error
	println(gr)
}