module builder



[heap]
pub struct NodesFactory {
pub mut:
	nodes map[string]&Node
}


//needed to get singleton
fn init_singleton() &NodesFactory {
	mut f := builder.NodesFactory{}	
	return &f
}

//singleton creation
const nodes_factory = init_singleton()



// pub enum Nodestate {
// 	init
// 	ok
// 	old
// }


// [heap]
// pub struct NodesFactory {
// pub mut:
// 	// lastscan	time.Time
// 	state		Nodestate
// }


// //needed to get singleton
// fn init_singleton() &NodesFactory {
// 	mut f := builder.NodesFactory{}	
// 	return &f
// }

// //singleton creation
// const nodesfactory = init_singleton()


// pub fn get() ?&NodesFactory {
// 	mut obj := builder.nodesfactory
// 	return obj
// }


