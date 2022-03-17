module mdbook

// import builder
import os



pub enum MDBookFactoryStatus {
	init
	ok
	error
}



[heap]
struct MDBookFactory {
mut:
	instances map[string]MDBookInstance
}


//needed to get singleton
fn init2() MDBookFactory {
	mut f := MDBookFactory{}	
	return f
}


//singleton creation
const factory = init2()

pub fn get() &MDBookFactory {
	return &mdbook.factory
}


